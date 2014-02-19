require 'active_support/all'
require 'dotenv'
require 'open-uri'

Dotenv.load

class WeatherGrabber
  
  def initialize
    @observation_id = ENV['OBSERVATION_LOCATION_ID']
    @forecast_id = ENV['FORECAST_LOCATION_ID']
  end
  
  def last_rain
    json = get "/wxobs/all/json/#{@observation_id}", res: "hourly"
    # Find last time there was rain
    json["SiteRep"]["DV"]["Location"]["Period"].reverse.each do |period|
      date = Date.parse(period["value"])
      period["Rep"].reverse.each do |forecast|
        if wet?(forecast["W"])
          return date + forecast['$'].to_i.minutes
        end
      end
    end
  end
  
  def next_rain
    # Find time of future forecasts
    json = get "/wxfcs/#{@forecast_id}/json/capabilities", res: "3hourly"
    forecasts = json['Resource']['TimeSteps']['TS'].select{|x| DateTime.parse(x) >= DateTime.now}.map{|x| DateTime.parse(x)}
    # Get forecasts
    json = get "/wxfcs/all/json/#{@forecast_id}", res: "3hourly"
    # Find next time there is a decent chance of rain
    json["SiteRep"]["DV"]["Location"]["Period"].each do |period|
      date = Date.parse(period["value"])
      period["Rep"].each do |forecast|
        if forecast["Pp"].to_i >= ENV["RAIN_THRESHOLD"].to_i
          return date + forecast['$'].to_i.minutes
        end
      end
    end
    nil
  end
  
  def outlook
    # Get forecasts
    json = get("/wxfcs/all/json/#{@forecast_id}", res: "daily")
    code = json["SiteRep"]["DV"]["Location"]["Period"][0]["Rep"][0]["W"]
    lookup_weather_code(code)
  end
  
  def temperature
    json = get "/wxobs/#{@observation_id}/json/capabilities", res: "hourly"
    @latest_observation_time = DateTime.parse(json['Resource']['TimeSteps']['TS'].last)
    json = get "/wxobs/all/json/#{@observation_id}", res: "hourly", time: crap_iso8601(@latest_observation_time)
    json["SiteRep"]["DV"]["Location"]["Period"]["Rep"]["T"].to_f
  end
  
  private
  
  def crap_iso8601(datetime)
    datetime.iso8601.gsub('+00:00','Z')
  end
  
  def wet?(code)
    (9..30).include?(code.to_i)
  end
  
  def lookup_weather_code(code)
    {
      0 =>   "Clear",
      1 =>   "Sunny",
      2 =>   "Partly cloudy",
      3 =>   "Partly cloudy",
      4 =>   "",
      5 =>   "Mist",
      6 =>   "Fog",
      7 =>   "Cloudy",
      8 =>   "Overcast",
      9 =>   "Light showers",
      10 =>  "Light showers",
      11 =>  "Drizzle",
      12 =>  "Light rain",
      13 =>  "Heavy showers",
      14 =>  "Heavy showers",
      15 =>  "Heavy rain",
      16 =>  "Sleet showers",
      17 =>  "Sleet showers",
      18 =>  "Sleet",
      19 =>  "Hail showers",
      20 =>  "Hail showers",
      21 =>  "Hail",
      22 =>  "Light snow showers",
      23 =>  "Light snow showers",
      24 =>  "Light snow",
      25 =>  "Heavy snow showers",
      26 =>  "Heavy snow showers",
      27 =>  "Heavy snow",
      28 =>  "Thundery showers",
      29 =>  "Thundery showers",
      30 =>  "Thunder",
    }[code.to_i]
  end
  
  def get(path, args = {})
    args.merge!(key: ENV['DATAPOINT_API_KEY'])
    url = "http://datapoint.metoffice.gov.uk/public/data/val#{path}?#{args.to_query}"
    
    JSON.parse(open(url).read)
  end
  
end
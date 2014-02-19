require 'active_support/all'
require 'dotenv'
require 'open-uri'

Dotenv.load

class WeatherGrabber
  
  def initialize
    @location_id = ENV['OBSERVATION_LOCATION_ID']
    @forecast_id = ENV['FORECAST_LOCATION_ID']
    @api_key = ENV['DATAPOINT_API_KEY']
  end
  
  def last_rain
    5.minutes.ago
  end
  
  def next_rain
    # Find time of future forecasts
    capabilities_url = "http://datapoint.metoffice.gov.uk/public/data/val/wxfcs/#{@forecast_id}/json/capabilities?res=3hourly&key=#{@api_key}"
    json = JSON.parse(open(capabilities_url).read)
    forecasts = json['Resource']['TimeSteps']['TS'].select{|x| DateTime.parse(x) >= DateTime.now}.map{|x| DateTime.parse(x)}
    # Get forecasts
    forecasts_url = "http://datapoint.metoffice.gov.uk/public/data/val/wxfcs/all/json/#{@forecast_id}?res=3hourly&key=#{@api_key}"
    json = JSON.parse(open(forecasts_url).read)    
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
    "Rainy"
  end
  
  def temperature
    capabilities_url = "http://datapoint.metoffice.gov.uk/public/data/val/wxobs/#{@location_id}/json/capabilities?res=hourly&key=#{@api_key}"
    json = JSON.parse(open(capabilities_url).read)
    @latest_observation_time = DateTime.parse(json['Resource']['TimeSteps']['TS'].last)
    observation_url = "http://datapoint.metoffice.gov.uk/public/data/val/wxobs/all/json/#{@location_id}?res=hourly&time=#{crap_iso8601(@latest_observation_time)}&key=#{@api_key}"
    json = JSON.parse(open(observation_url).read)
    json["SiteRep"]["DV"]["Location"]["Period"]["Rep"]["T"].to_f
  end
  
  private
  
  def crap_iso8601(datetime)
    datetime.iso8601.gsub('+00:00','Z')
  end
  
end
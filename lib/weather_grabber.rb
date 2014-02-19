require 'active_support/all'
require 'dotenv'
require 'open-uri'

Dotenv.load

class WeatherGrabber
  
  def initialize
    @location_id = ENV['OBSERVATION_LOCATION_ID']
    @api_key = ENV['DATAPOINT_API_KEY']
  end
  
  def last_rain
    5.minutes.ago
  end
  
  def next_rain
    2.hours.from_now
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
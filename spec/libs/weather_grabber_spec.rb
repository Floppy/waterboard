require 'spec_helper'
require_relative '../../lib/weather_grabber'

describe WeatherGrabber, :vcr do
  
  before :all do    
    @weather = WeatherGrabber.new
    Timecop.freeze
  end
  
  it "should give back the last time there was rain" do
    @weather.last_rain.should == 5.minutes.ago
  end
    
  it "should give back the next time there will be rain" do
    @weather.next_rain.should == 2.hours.from_now
  end
  
  it "should give back the current temperature" do
    @weather.temperature.should == 3
  end

  it "should give back the outlook" do
    @weather.outlook.should == "Rainy"
  end

  after :all do
    Timecop.return
  end

end
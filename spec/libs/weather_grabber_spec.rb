require 'spec_helper'
require_relative '../../lib/weather_grabber'

describe WeatherGrabber, :vcr do
  
  before :each do    
    @weather = WeatherGrabber.new
    Timecop.freeze(2014,02,19,13,00)
  end
  
  it "should give back the last time there was rain" do
    @weather.last_rain.should == 5.minutes.ago
  end
    
  it "should give back the next time there will be rain" do
    @weather.next_rain.should == DateTime.new(2014,02,20,00,00)
  end
  
  it "should give back the current temperature" do
    @weather.temperature.should == 8.8
  end

  it "should give back the outlook" do
    @weather.outlook.should == "Rainy"
  end

  after :all do
    Timecop.return
  end

end
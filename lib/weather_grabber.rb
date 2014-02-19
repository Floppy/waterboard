require 'active_support/all'

class WeatherGrabber
  
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
    3
  end
  
end
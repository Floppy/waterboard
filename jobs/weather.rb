SCHEDULER.every '10m', :first_in => 0 do
  
  weather = WeatherGrabber.new
  
  send_event 'next-rain',   text:    weather.next_rain
  send_event 'last-rain',   text:    weather.last_rain
  send_event 'temperature', current: weather.temperature, suffix: "°"
  send_event 'outlook',     text:    weather.outlook

end
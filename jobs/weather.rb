require 'action_view'

SCHEDULER.every '10m', :first_in => 0 do
  
  weather = WeatherGrabber.new
  
  include ActionView::Helpers::DateHelper
  
  send_event 'next-rain',   text:    "in " + time_ago_in_words(weather.next_rain)
  send_event 'last-rain',   text:    time_ago_in_words(weather.last_rain) + " ago"
  send_event 'temperature', current: weather.temperature, suffix: "°"
  send_event 'outlook',     text:    weather.outlook

end
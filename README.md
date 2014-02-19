# Waterboard

A very simple weather dashboard, designed to help decide what waterproofs to wear when cycling to the station.

## License

MIT. See LICENSE.md

## Usage

```
bundle
dashing start
open http://localhost:3030/weather
```

## Data Sources

The app was written as a way to explore the Met Office's DataPoint service. All data comes from there. See `lib/weather_grabber.rb` for more details.
require "../src/uing"

# Application constants
WINDOW_TITLE    = "World Clock"
WINDOW_WIDTH    =  700
WINDOW_HEIGHT   =  700
UPDATE_INTERVAL = 1000 # milliseconds
TIME_FORMAT     = "%H:%M:%S"

# City data structure for type safety
struct CityInfo
  getter name : String
  getter timezone : String
  getter flag : String

  def initialize(@name : String, @timezone : String, @flag : String)
  end
end

# UI component to hold timezone and its corresponding label
struct CityTimeLabel
  getter timezone : String
  getter label : UIng::Label

  def initialize(@timezone : String, @label : UIng::Label)
  end
end

# World cities data (sorted by time zone from east to west for global coverage)
WORLD_CITIES = [
  # Pacific Region
  CityInfo.new("Auckland", "Pacific/Auckland", "🇳🇿"),
  CityInfo.new("Fiji", "Pacific/Fiji", "🇫🇯"),
  CityInfo.new("Sydney", "Australia/Sydney", "🇦🇺"),
  CityInfo.new("Port Moresby", "Pacific/Port_Moresby", "🇵🇬"),

  # East Asia
  CityInfo.new("Tokyo", "Asia/Tokyo", "🇯🇵"),
  CityInfo.new("Seoul", "Asia/Seoul", "🇰🇷"),
  CityInfo.new("Pyongyang", "Asia/Pyongyang", "🇰🇵"),
  CityInfo.new("Beijing", "Asia/Shanghai", "🇨🇳"),
  CityInfo.new("Hong Kong", "Asia/Hong_Kong", "🇭🇰"),
  CityInfo.new("Taipei", "Asia/Taipei", "🇹🇼"),
  CityInfo.new("Ulaanbaatar", "Asia/Ulaanbaatar", "🇲🇳"),

  # Southeast Asia
  CityInfo.new("Hanoi", "Asia/Bangkok", "🇻🇳"),
  CityInfo.new("Bangkok", "Asia/Bangkok", "🇹🇭"),
  CityInfo.new("Jakarta", "Asia/Jakarta", "🇮🇩"),
  CityInfo.new("Singapore", "Asia/Singapore", "🇸🇬"),
  CityInfo.new("Kuala Lumpur", "Asia/Kuala_Lumpur", "🇲🇾"),
  CityInfo.new("Manila", "Asia/Manila", "🇵🇭"),

  # South Asia
  CityInfo.new("Dhaka", "Asia/Dhaka", "🇧🇩"),
  CityInfo.new("Mumbai", "Asia/Kolkata", "🇮🇳"),
  CityInfo.new("Karachi", "Asia/Karachi", "🇵🇰"),

  # Middle East
  CityInfo.new("Tehran", "Asia/Tehran", "🇮🇷"),
  CityInfo.new("Dubai", "Asia/Dubai", "🇦🇪"),
  CityInfo.new("Riyadh", "Asia/Riyadh", "🇸🇦"),
  CityInfo.new("Baghdad", "Asia/Baghdad", "🇮🇶"),
  CityInfo.new("Jerusalem", "Asia/Jerusalem", "🇮🇱"),

  # Eastern Europe & Western Asia
  CityInfo.new("Istanbul", "Europe/Istanbul", "🇹🇷"),
  CityInfo.new("Kyiv", "Europe/Kyiv", "🇺🇦"),
  CityInfo.new("Warsaw", "Europe/Warsaw", "🇵🇱"),
  CityInfo.new("Moscow", "Europe/Moscow", "🇷🇺"),

  # Africa
  CityInfo.new("Cairo", "Africa/Cairo", "🇪🇬"),
  CityInfo.new("Nairobi", "Africa/Nairobi", "🇰🇪"),
  CityInfo.new("Lagos", "Africa/Lagos", "🇳🇬"),
  CityInfo.new("Johannesburg", "Africa/Johannesburg", "🇿🇦"),

  # Western Europe
  CityInfo.new("Madrid", "Europe/Madrid", "🇪🇸"),
  CityInfo.new("Stockholm", "Europe/Stockholm", "🇸🇪"),
  CityInfo.new("Paris", "Europe/Paris", "🇫🇷"),
  CityInfo.new("Berlin", "Europe/Berlin", "🇩🇪"),
  CityInfo.new("Rome", "Europe/Rome", "🇮🇹"),
  CityInfo.new("London", "Europe/London", "🇬🇧"),

  # UTC Reference
  CityInfo.new("UTC", "UTC", "🌐"),

  # South America
  CityInfo.new("Buenos Aires", "America/Argentina/Buenos_Aires", "🇦🇷"),
  CityInfo.new("Santiago", "America/Santiago", "🇨🇱"),
  CityInfo.new("Lima", "America/Lima", "🇵🇪"),
  CityInfo.new("Bogota", "America/Bogota", "🇨🇴"),
  CityInfo.new("Sao Paulo", "America/Sao_Paulo", "🇧🇷"),

  # North America
  CityInfo.new("New York", "America/New_York", "🇺🇸"),
  CityInfo.new("Toronto", "America/Toronto", "🇨🇦"),
  CityInfo.new("Havana", "America/Havana", "🇨🇺"),
  CityInfo.new("Mexico City", "America/Mexico_City", "🇲🇽"),
  CityInfo.new("Chicago", "America/Chicago", "🇺🇸"),
  CityInfo.new("Vancouver", "America/Vancouver", "🇨🇦"),
  CityInfo.new("Los Angeles", "America/Los_Angeles", "🇺🇸"),
  CityInfo.new("Anchorage", "America/Anchorage", "🇺🇸"),
  CityInfo.new("Honolulu", "Pacific/Honolulu", "🇺🇸"),
]

# Get time-of-day emoji based on hour (0-23)
def get_time_emoji(hour : Int32) : String
  case hour
  when 0..3   then "🛌"  # sleeping
  when 4..5   then "🌃"  # late night
  when 6      then "🌄"  # dawn
  when 7..10  then "☀️" # morning
  when 11     then "🍽️" # lunch time
  when 12     then "🕛"  # noon
  when 13..15 then "🌤️" # afternoon
  when 16..17 then "🌇"  # dusk
  when 18..20 then "🌆"  # evening
  else             "🌙"  # night
  end
end

# Update all time labels with current time and appropriate emoji
def update_clocks(time_labels : Array(CityTimeLabel)) : Nil
  time_labels.each do |city_time_label|
    begin
      location = Time::Location.load(city_time_label.timezone)
      now = Time.local(location)
      emoji = get_time_emoji(now.hour)
      city_time_label.label.text = "#{emoji} #{now.to_s(TIME_FORMAT)}"
    rescue ex
      # Handle timezone loading errors gracefully
      city_time_label.label.text = "❌ Error"
    end
  end
end

# Create and configure the main application window
def create_window : UIng::Window
  window = UIng::Window.new(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT)
  window.margined = true
  window.on_closing do
    UIng.quit
    true
  end
  window
end

# Build the box layout with cities in two columns
def build_box_layout(cities : Array(CityInfo)) : {UIng::Box, Array(CityTimeLabel)}
  # Split cities into two columns for better space utilization
  mid = (cities.size / 2.0).ceil.to_i
  left_cities = cities[0...mid]
  right_cities = cities[mid..-1]

  # Main horizontal container
  main_box = UIng::Box.new(:horizontal)
  main_box.padded = true

  time_labels = [] of CityTimeLabel

  # Left column
  left_column = UIng::Box.new(:vertical)
  left_column.padded = true

  left_cities.each do |city|
    # Container for each city row
    city_row = UIng::Box.new(:horizontal)
    city_row.padded = true

    name_label = UIng::Label.new("#{city.flag} #{city.name}")
    time_label = UIng::Label.new("00:00:00")

    city_row.append(name_label, stretchy: true)
    city_row.append(time_label, stretchy: false)

    left_column.append(city_row, stretchy: false)
    time_labels << CityTimeLabel.new(city.timezone, time_label)
  end

  # Add left column to main container
  main_box.append(left_column, stretchy: true)

  # Add vertical separator
  separator = UIng::Separator.new(:vertical)
  main_box.append(separator, stretchy: false)

  # Right column
  right_column = UIng::Box.new(:vertical)
  right_column.padded = true

  right_cities.each do |city|
    # Container for each city row
    city_row = UIng::Box.new(:horizontal)
    city_row.padded = true

    name_label = UIng::Label.new("#{city.flag} #{city.name}")
    time_label = UIng::Label.new("00:00:00")

    city_row.append(name_label, stretchy: true)
    city_row.append(time_label, stretchy: false)

    right_column.append(city_row, stretchy: false)
    time_labels << CityTimeLabel.new(city.timezone, time_label)
  end

  # Add right column to main container
  main_box.append(right_column, stretchy: true)

  {main_box, time_labels}
end

# Main application entry point
def main
  # Initialize UIng
  UIng.init

  # Create main window
  window = create_window

  # Build the UI layout
  main_box, time_labels = build_box_layout(WORLD_CITIES)
  window.child = main_box

  # Initial time update
  update_clocks(time_labels)

  # Set up periodic updates
  UIng.timer(UPDATE_INTERVAL) do
    update_clocks(time_labels)
    1 # Continue timer
  end

  # Show window and start main loop
  window.show
  UIng.main
  UIng.uninit
end

# Run the application
main

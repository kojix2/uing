require "../src/uing"

# Application constants
WINDOW_TITLE     = "World Clock"
WINDOW_WIDTH     = 700
WINDOW_HEIGHT    = 700
UPDATE_INTERVAL  = 1000 # milliseconds
TIME_FORMAT      = "%H:%M:%S"

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
  when 0..3   then "🛌" # sleeping
  when 4..5   then "🌃" # late night
  when 6      then "🌄" # dawn
  when 7..10  then "☀️" # morning
  when 11     then "🍽️" # lunch time
  when 12     then "🕛" # noon
  when 13..15 then "🌤️" # afternoon
  when 16..17 then "🌇" # dusk
  when 18..20 then "🌆" # evening
  else             "🌙" # night
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

# Build the grid layout with cities in two columns
def build_grid_layout(cities : Array(CityInfo)) : {UIng::Grid, Array(CityTimeLabel)}
  # Split cities into two columns for better space utilization
  mid = (cities.size / 2.0).ceil.to_i
  left_cities = cities[0...mid]
  right_cities = cities[mid..-1]

  grid = UIng::Grid.new
  grid.padded = true

  time_labels = [] of CityTimeLabel

  # Add left column cities
  left_cities.each_with_index do |city, row|
    name_label = UIng::Label.new("#{city.flag} #{city.name}")
    time_label = UIng::Label.new("00:00:00")
    
    grid.append(name_label, left: 0, top: row, xspan: 1, yspan: 1, 
                hexpand: true, halign: :fill, vexpand: false, valign: :fill)
    grid.append(time_label, left: 1, top: row, xspan: 1, yspan: 1, 
                hexpand: true, halign: :fill, vexpand: false, valign: :fill)
    
    time_labels << CityTimeLabel.new(city.timezone, time_label)
  end

  # Add vertical separator between columns
  separator = UIng::Separator.new(:vertical)
  grid.append(separator, left: 2, top: 0, xspan: 1, yspan: left_cities.size, 
              hexpand: false, halign: :fill, vexpand: true, valign: :fill)

  # Add right column cities (offset by separator)
  right_cities.each_with_index do |city, row|
    name_label = UIng::Label.new("#{city.flag} #{city.name}")
    time_label = UIng::Label.new("00:00:00")
    
    grid.append(name_label, left: 3, top: row, xspan: 1, yspan: 1, 
                hexpand: true, halign: :fill, vexpand: false, valign: :fill)
    grid.append(time_label, left: 4, top: row, xspan: 1, yspan: 1, 
                hexpand: true, halign: :fill, vexpand: false, valign: :fill)
    
    time_labels << CityTimeLabel.new(city.timezone, time_label)
  end

  {grid, time_labels}
end

# Main application entry point
def main
  # Initialize UIng
  UIng.init

  # Create main window
  window = create_window

  # Build the UI layout
  grid, time_labels = build_grid_layout(WORLD_CITIES)
  window.child = grid

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

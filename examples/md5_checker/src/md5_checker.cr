require "./checker"
require "./table_handler"
require "./app"

# Redirect stdout and stderr to temp file when not in debug mode
# This is needed for Windows builds with -mwindows or /SUBSYSTEM:WINDOWS
{% unless flag?(:debug) %}
  temp_output = File.tempfile("md5checker_output")  
  STDOUT.reopen(temp_output)  
  STDERR.reopen(temp_output)  
  
  begin
    # Run the application
    app = MD5CheckerApp.new
    app.run
  ensure
    temp_output.delete if temp_output
  end
{% else %}
  # Run the application
  app = MD5CheckerApp.new
  app.run
{% end %}

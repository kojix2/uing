require "digest/md5"

# File verification result
struct FileResult
  property filename : String
  property status : String
  property message : String

  def initialize(@filename : String, @status : String, @message : String)
  end

  # Convert status to emoji
  def status_emoji
    case @status
    when "OK"    then "✅"
    when "FAIL"  then "❌"
    when "ERROR" then "⚠️"
    else              "❓"
    end
  end

  # Get display status with emoji
  def display_status
    "#{status_emoji} #{@status}"
  end
end

# MD5 checker application
class MD5Checker
  # Singleton pattern
  @@instance = new

  def self.instance
    @@instance
  end

  private def initialize
    @results = [] of FileResult
  end

  # Results storage
  getter results : Array(FileResult)

  # Clear results
  def clear_results
    @results.clear
  end

  # Get result count
  def result_count
    @results.size
  end

  # Get result at index for table display
  def result_at(index, column)
    return "" if index >= @results.size

    result = @results[index]
    case column
    when 0 then result.filename
    when 1 then result.display_status
    when 2 then result.message
    else        ""
    end
  end

  # Calculate MD5 hash for a file
  private def calculate_md5(file_path : String) : String
    Digest::MD5.hexdigest(File.read(file_path))
  end

  # Process MD5 checksum file
  def process_md5_file(md5_file_path : String) : Nil
    @results.clear

    # Check if file exists
    unless File.exists?(md5_file_path)
      @results << FileResult.new("File not found", "ERROR", md5_file_path)
      return
    end

    begin
      # Process each line in the file
      line_number = 0
      File.each_line(md5_file_path) do |line|
        line_number += 1
        begin
          process_line(line, line_number, md5_file_path)
        rescue ex : Exception
          @results << FileResult.new("Line #{line_number}", "ERROR", "Parse error: #{ex.message}")
        end
      end
    rescue ex : Exception
      @results << FileResult.new("File error", "ERROR", "Failed to read file: #{ex.message}")
    end
  end

  # Process a single line from the MD5 file
  private def process_line(line, line_number, md5_file_path)
    # Skip empty lines
    return if line.strip.empty?

    # Parse line (format: "MD5hash filename")
    parts = line.strip.split(' ', 2)
    if parts.size < 2
      @results << FileResult.new("Line #{line_number}", "ERROR", "Invalid format")
      return
    end

    expected_hash = parts[0].downcase
    # Validate MD5 hash format (32 hex characters)
    unless expected_hash =~ /^[0-9a-f]{32}$/
      @results << FileResult.new("Line #{line_number}", "ERROR", "Invalid MD5 hash format")
      return
    end

    filename = parts[1].strip
    file_path = File.join(File.dirname(md5_file_path), filename)

    # Check if file exists
    unless File.exists?(file_path)
      @results << FileResult.new(filename, "ERROR", "File not found")
      return
    end

    # Calculate and compare MD5 hash
    begin
      actual_hash = calculate_md5(file_path)
      if actual_hash.downcase == expected_hash
        @results << FileResult.new(filename, "OK", "Verification successful")
      else
        @results << FileResult.new(filename, "FAIL", "Checksum mismatch")
      end
    rescue ex : Exception
      @results << FileResult.new(filename, "ERROR", "Failed to calculate MD5: #{ex.message}")
    end
  end
end

require "digest/md5"

# MD5 checker application
class MD5Checker
  # Singleton pattern
  @@instance = new

  def self.instance
    @@instance
  end

  private def initialize
    @results = [] of {String, String, String} # filename, status, message
  end

  # Results storage
  getter results : Array({String, String, String})

  # Clear results
  def clear_results
    @results.clear
  end

  # Add result
  def add_result(result)
    @results << result
  end

  # Get result count
  def result_count
    @results.size
  end

  # Get result at index
  def result_at(index, column)
    if index < @results.size
      @results[index][column]
    else
      ""
    end
  end

  # Calculate MD5 hash for a file
  def calculate_md5(file_path)
    Digest::MD5.new.file(file_path).hexfinal
  end

  # Process MD5 checksum file
  def process_md5_file(md5_file_path)
    local_results = [] of {String, String, String}

    # Check if file exists
    unless File.exists?(md5_file_path)
      local_results << {"File not found", "ERROR", md5_file_path}
      return local_results
    end

    begin
      # Process each line in the file
      line_number = 0
      File.each_line(md5_file_path) do |line|
        line_number += 1
        begin
          process_line(line, line_number, md5_file_path, local_results)
        rescue ex : Exception
          # Handle line parsing errors
          local_results << {"Line #{line_number}", "ERROR", "Parse error: #{ex.message}"}
        end
      end
    rescue ex : Exception
      # Handle file reading errors
      local_results << {"File error", "ERROR", "Failed to read file: #{ex.message}"}
    end

    local_results
  end

  # Process a single line from the MD5 file
  private def process_line(line, line_number, md5_file_path, results)
    # Skip empty lines
    return if line.strip.empty?

    # Parse line (format: "MD5hash filename")
    parts = line.strip.split(' ', 2)
    if parts.size < 2
      results << {"Line #{line_number}", "ERROR", "Invalid format"}
      return
    end

    expected_hash = parts[0].downcase
    # Validate MD5 hash format (32 hex characters)
    unless expected_hash =~ /^[0-9a-f]{32}$/
      results << {"Line #{line_number}", "ERROR", "Invalid MD5 hash format"}
      return
    end

    filename = parts[1].strip

    # Build file path (assuming files are in the same directory as md5.txt)
    file_path = File.join(File.dirname(md5_file_path), filename)
    # Check if file exists
    unless File.exists?(file_path)
      results << {filename, "ERROR", "File not found"}
      return
    end

    # Calculate actual MD5 hash
    begin
      actual_hash = calculate_md5(file_path)

      # Compare hashes
      if actual_hash.downcase == expected_hash
        results << {filename, "OK", "Verification successful"}
      else
        results << {filename, "FAIL", "Checksum mismatch (expected: #{expected_hash}, actual: #{actual_hash})"}
      end
    rescue ex : Exception
      results << {filename, "ERROR", "Failed to calculate MD5: #{ex.message}"}
    end
  end
end

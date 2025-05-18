# This file handles downloading and extracting libui-ng library files for different platforms
require "file_utils"
require "compress/zip"
require "crest"

# Generates the URL for downloading a specific libui-ng nightly build file
def url_for_libui_ng_nightly(file_name : String) : String
  "https://nightly.link/kojix2/libui-ng/workflows/pre-build/pre-build/#{file_name}"
end

# Downloads a libui-ng nightly build for the specified library path and file name
def download_libui_ng_nightly(lib_paths : Array(String), file_name : String) : Nil
  url = url_for_libui_ng_nightly(file_name)
  download_from_url(lib_paths, file_name, url)
end

# Downloads and processes a file from the specified URL
# - lib_paths: Array of paths to look for in zip archives
# - file_name: Name to save the downloaded file as
# - url: URL to download from
def download_from_url(lib_paths : Array(String) | String, file_name : String, url : String) : Nil
  puts "Downloading #{lib_paths} from #{url}"

  begin
    # Download the file
    Crest.get(url) do |response|
      File.open(file_name, "wb") do |file|
        IO.copy(response.body_io, file)
      end
    end

    # Process the downloaded file based on its extension
    case file_name
    when /\.zip$/
      extract_from_zip(file_name, lib_paths)
    when /\.a$/
      # Copy libui_x86_64_win.a to libui.a
      FileUtils.cp(file_name, "libui.a")
      puts "Copied #{file_name} to libui.a"
    else
      raise "Unknown file type: #{file_name}"
    end
  rescue ex : Exception
    puts "Error during download or extraction: #{ex.message}"
    raise ex
  ensure
    # Clean up the downloaded file
    File.delete(file_name) if File.exists?(file_name)
  end
end

# Extracts specific files from a zip archive
private def extract_from_zip(zip_file_name : String, target_paths : Array(String) | String) : Nil
  Compress::Zip::File.open(zip_file_name) do |zip_file|
    zip_file.entries.each do |entry|
      if target_paths.is_a?(String) && entry.filename.includes?(target_paths) ||
         target_paths.is_a?(Array) && target_paths.any? { |path| entry.filename.includes?(path) }
        print "Extracting #{entry.filename} from #{zip_file_name}..."
        entry.open do |io|
          File.open(File.basename(entry.filename), "wb") do |file|
            IO.copy(io, file)
          end
        end
        puts "done"
      end
    end
  end
end

# Platform-specific download logic
{% if flag?(:darwin) %}
  # macOS build
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "macOS-x64-static-release.zip"
  )
{% elsif flag?(:linux) %}
  # Linux build
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Ubuntu-x64-static-release.zip"
  )
{% elsif flag?(:msvc) %}
  # Windows MSVC build
  download_libui_ng_nightly(
    # ["builddir/meson-out/libui.dll", "builddir/meson-out/libui.lib"],
    ["builddir/meson-out/libui.a"],
    "Win-x64-static-release.zip"
  )
{% elsif flag?(:win32) && flag?(:gnu) %}
  # Windows MinGW build
  download_from_url(
    "libui.a",
    "libui_x86_64_win.a",
    "https://github.com/petabyt/libui-dev/releases/download/5-beta/libui_x86_64_win.a"
  )
  # Compile Windows resource file
  system(p("windres comctl32.rc -O coff -o comctl32.res"))
{% end %}

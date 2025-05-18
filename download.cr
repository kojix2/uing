require "compress/zip"
require "crest"

def url_for_libui_ng_nightly(file_name : String) : String
  "https://nightly.link/kojix2/libui-ng/workflows/pre-build/pre-build/#{file_name}"
end

def download_from_url(lib_paths : Array(String), file_name : String, url : String) : Nil
  puts "Downloading #{file_name} from #{url}"

  begin
    Crest::Request.get(url) do |response|
      File.open(file_name, "w") { |f| IO.copy(response.body_io, f) }
    end

    case file_name
    when /\.zip$/
      extract_from_zip(file_name, lib_paths)
    when /\.a$/
      File.copy(file_name, lib_paths.first)
      puts "Copied #{file_name} to #{lib_paths.first}"
    else
      raise "Unknown file type: #{file_name}"
    end
  rescue ex
    STDERR.puts "Error: #{ex.message}"
    raise ex
  ensure
    File.delete(file_name) if File.exists?(file_name)
  end
end

private def extract_from_zip(zip_file_name : String, target_paths : Array(String)) : Nil
  Compress::Zip::File.open(zip_file_name) do |zip|
    zip.entries.each do |entry|
      normalized = entry.filename.gsub("\\", "/")
      target_paths.each do |target|
        if normalized.ends_with?(target) || File.basename(normalized) == target
          puts "Extracting #{entry.filename}"
          entry.open do |io|
            File.open(File.basename(entry.filename), "wb") { |f| IO.copy(io, f) }
          end
          break
        end
      end
    end
  end
end

{% if flag?(:darwin) %}
  download_from_url(["libui.a"], "macOS-x64-static-release.zip", url_for_libui_ng_nightly("macOS-x64-static-release.zip"))
{% elsif flag?(:linux) %}
  download_from_url(["libui.a"], "Ubuntu-x64-static-release.zip", url_for_libui_ng_nightly("Ubuntu-x64-static-release.zip"))
{% elsif flag?(:msvc) %}
  download_from_url(["libui.dll", "libui.lib"], "Win-x64-static-release.zip", url_for_libui_ng_nightly("Win-x64-static-release.zip"))
{% elsif flag?(:win32) && flag?(:gnu) %}
  download_from_url(["libui.a"], "libui_x86_64_win.a", "https://github.com/petabyt/libui-dev/releases/download/5-beta/libui_x86_64_win.a")
  system("windres comctl32.rc -O coff -o comctl32.res")
{% end %}

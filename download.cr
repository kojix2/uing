require "compress/zip"
require "crest"

def url_for_libui_ng_nightly(file_name)
  "https://nightly.link/kojix2/libui-ng/workflows/pre-build/pre-build/#{file_name}"
end

def download_libui_ng_nightly(libname, lib_path, file_name)
  url = url_for_libui_ng_nightly(file_name)
  download_from_url(libname, lib_path, file_name, url)
end

def download_from_url(libname, lib_path, file_name, url)
  STDERR.puts "Downloading #{libname} from #{url}"

  Crest.get(url) do |response|
    File.open(file_name, "wb") do |file|
      IO.copy(response.body_io, file)
    end
  end

  if file_name.ends_with?(".zip")
    Compress::Zip::File.open(file_name) do |zip_file|
      zip_file.entries.each do |entry|
        if entry.filename == lib_path
          entry.open do |io|
            File.open(libname, "wb") do |file|
              IO.copy(io, file)
            end
          end
        end
      end
    end
  end

  File.delete(file_name)
end

{% if flag?(:darwin) %}
  download_libui_ng_nightly(
    "libui.dylib",
    "builddir/meson-out/libui.dylib",
    "macOS-x64-shared-release.zip"
  )
{% elsif flag?(:linux) %}
  download_libui_ng_nightly(
    "libui.so",
    "builddir/meson-out/libui.so",
    "Ubuntu-x64-shared-release.zip"
  )
{% elsif flag?(:windows) %}
  download_libui_ng_nightly(
    "libui.dll",
    "builddir/meson-out/libui.dll",
    "Win-x64-shared-release.zip"
  )
{% end %}

require "compress/zip"
require "file_utils"

COMMIT_HASH = "43ba1ef"

def url_for_libui_ng_nightly(file_name)
  "https://github.com/kojix2/libui-ng/releases/download/commit-#{COMMIT_HASH}/#{file_name}"
end

def download_libui_ng_nightly(lib_path, file_name)
  url = url_for_libui_ng_nightly(file_name)
  download_from_url(lib_path, file_name, url)
end

def download_from_url(lib_path, file_name, url)
  puts "Downloading #{lib_path} from #{url}"

  # Use curl command instead of Crest
  system("curl -L -o #{file_name} #{url}")

  if file_name.ends_with?(".zip")
    Compress::Zip::File.open(file_name) do |zip_file|
      zip_file.entries.each do |entry|
        if lib_path.any? { |path| entry.filename == path || entry.filename.starts_with?(path + "/") }
          print "Extracting #{entry.filename} from #{file_name}..."

          # Preserve complete directory structure
          target_path = entry.filename
          FileUtils.mkdir_p(File.dirname(target_path)) unless entry.dir?

          unless entry.dir?
            entry.open do |io|
              File.open(target_path, "wb") do |file|
                IO.copy(io, file)
              end
            end
          end
          puts "done"
        end
      end
    end
  end
ensure
  File.delete(file_name) if File.exists?(file_name)
end

{% if flag?(:darwin) %}
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "macOS-x64-static-release.zip"
  )
  FileUtils.mkdir_p "libui/release"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/release/libui.a"
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "macOS-x64-static-debug.zip"
  )
  FileUtils.mkdir_p "libui/debug"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/debug/libui.a"
{% elsif flag?(:linux) %}
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Ubuntu-x64-static-release.zip"
  )
  FileUtils.mkdir_p "libui/release"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/release/libui.a"
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Ubuntu-x64-static-debug.zip"
  )
  FileUtils.mkdir_p "libui/debug"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/debug/libui.a"
{% elsif flag?(:msvc) %}
  # Release build
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Win-x64-static-release.zip"
  )
  FileUtils.mkdir_p "libui/release"
  FileUtils.cp "builddir/meson-out/libui.a", "libui/release/ui.lib"

  # Debug build (including PDB files)
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a", "builddir/meson-out/libui.a.p"],
    "Win-x64-static-debug.zip"
  )
  FileUtils.mkdir_p "libui/debug"
  FileUtils.cp "builddir/meson-out/libui.a", "libui/debug/ui.lib"
  # Copy entire libui.a.p/ directory
  if Dir.exists?("builddir/meson-out/libui.a.p")
    FileUtils.cp_r "builddir/meson-out/libui.a.p", "libui/debug/"
  end
{% elsif flag?(:win32) && flag?(:gnu) %}
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Mingw-x64-static-release.zip"
  )
  FileUtils.mkdir_p "libui/release"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/release/libui.a"
  download_libui_ng_nightly(
    ["builddir/meson-out/libui.a"],
    "Mingw-x64-static-debug.zip"
  )
  FileUtils.mkdir_p "libui/debug"
  FileUtils.mv "builddir/meson-out/libui.a", "libui/debug/libui.a"
  system(p("windres comctl32.rc -O coff -o comctl32.res"))
{% end %}

# {% if flag?(:win32) && flag?(:gnu) %}
#   file_name = "libui.a"
#   url = "https://github.com/petabyt/libui-dev/releases/download/5-beta/libui_x86_64_win.a"
#   system("curl -L #{url} -o #{file_name}")
#   system(p("windres comctl32.rc -O coff -o comctl32.res"))
#   exit 0
# {% end %}

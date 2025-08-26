require "compress/zip"
require "file_utils"

COMMIT_HASH = ENV["LIBUI_NG_COMMIT_HASH"]? || "703e6cf-experimental"

# Path constants
BUILD_DIR      = "builddir"
MESON_OUT_DIR  = "#{BUILD_DIR}/meson-out"
LIBUI_SOURCE   = "#{MESON_OUT_DIR}/libui.a"
PDB_SOURCE_DIR = "#{MESON_OUT_DIR}/libui.a.p"
DEBUG_DIR      = "libui/debug"
PDB_DEST_DIR   = "#{DEBUG_DIR}/libui.a.p"

# Platform-specific configuration with architecture support
PLATFORM_CONFIG = {
  # macOS Intel x86_64
  darwin_x64: [
    {zip: "macOS-x64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "macOS-x64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # macOS Apple Silicon ARM64
  darwin_arm64: [
    {zip: "macOS-arm64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "macOS-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # Linux x86_64
  linux_x64: [
    {zip: "Ubuntu-x64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "Ubuntu-x64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # Linux ARM64
  linux_arm64: [
    {zip: "Ubuntu-arm64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "Ubuntu-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # Linux ARM 32-bit
  linux_arm: [
    {zip: "Ubuntu-arm-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "Ubuntu-arm-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # Windows MSVC x86_64
  msvc_x64: [
    {zip: "Win-x64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/ui.lib"},
    {zip: "Win-x64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/ui.lib", extra_pdb: true},
  ],
  # Windows MSVC x86 32-bit
  msvc_x86: [
    {zip: "Win-x86-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/ui.lib"},
    {zip: "Win-x86-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/ui.lib", extra_pdb: true},
  ],
  # Windows MinGW x86_64
  mingw_x64: [
    {zip: "Mingw-x64-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "Mingw-x64-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
  # Windows MinGW x86 32-bit
  mingw_x86: [
    {zip: "Mingw-x86-static-release.zip", src: LIBUI_SOURCE, dest: "libui/release/libui.a"},
    {zip: "Mingw-x86-static-debug.zip", src: LIBUI_SOURCE, dest: "libui/debug/libui.a"},
  ],
}

# Low-level utility functions
def url_for_libui_ng_nightly(file_name)
  "https://github.com/kojix2/libui-ng/releases/download/commit-#{COMMIT_HASH}/#{file_name}"
end

def download_file(file_name, url)
  puts "Running: curl -L -o #{file_name} #{url}"
  curl_status = system("curl -L -o #{file_name} #{url}")
  unless curl_status && File.exists?(file_name)
    STDERR.puts "Error: Failed to download #{file_name} from #{url}"
    exit 1
  end
end

def extract_zip_files(file_name, lib_path)
  return unless file_name.ends_with?(".zip")

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

def download_from_url(lib_path, file_name, url)
  puts "Downloading #{lib_path} from #{url}"

  download_file(file_name, url)
  extract_zip_files(file_name, lib_path)
ensure
  File.delete(file_name) if File.exists?(file_name)
end

# Mid-level functions
def download_libui_ng_nightly(lib_path, file_name)
  url = url_for_libui_ng_nightly(file_name)
  download_from_url(lib_path, file_name, url)
end

def download_and_place(zip_name : String, src : String, dest : String)
  download_libui_ng_nightly([src], zip_name)
  FileUtils.mkdir_p File.dirname(dest)
  FileUtils.cp src, dest
end

def process_msvc_pdb_files(entry)
  download_libui_ng_nightly([LIBUI_SOURCE, PDB_SOURCE_DIR], entry[:zip])
  FileUtils.mkdir_p File.dirname(entry[:dest])
  FileUtils.cp LIBUI_SOURCE, entry[:dest]

  # Copy entire libui.a.p/ directory
  if Dir.exists?(PDB_SOURCE_DIR)
    FileUtils.cp_r PDB_SOURCE_DIR, DEBUG_DIR
    # Copy PDB files to the same directory as ui.lib for linker to find them
    Dir.glob("#{PDB_DEST_DIR}/*.pdb").each do |pdb_file|
      FileUtils.cp pdb_file, DEBUG_DIR
    end
  end
end

# High-level processing functions
def process_config_entry(entry)
  if entry[:extra_pdb]?
    # MSVC Debug build with PDB files
    process_msvc_pdb_files(entry)
  else
    # Standard download and place
    download_and_place(entry[:zip], entry[:src], entry[:dest])
  end
end

def process_platform(platform_entries)
  platform_entries.each do |entry|
    process_config_entry(entry)
  end
end

# Platform-specific processing with architecture detection
{% if flag?(:darwin) %}
  {% if flag?(:x86_64) %}
    process_platform(PLATFORM_CONFIG[:darwin_x64])
  {% elsif flag?(:aarch64) %}
    process_platform(PLATFORM_CONFIG[:darwin_arm64])
  {% else %}
    {% raise "Unsupported Darwin architecture. Supported: x86_64, aarch64" %}
  {% end %}
{% elsif flag?(:linux) %}
  {% if flag?(:x86_64) %}
    process_platform(PLATFORM_CONFIG[:linux_x64])
  {% elsif flag?(:aarch64) %}
    process_platform(PLATFORM_CONFIG[:linux_arm64])
  {% elsif flag?(:arm) %}
    process_platform(PLATFORM_CONFIG[:linux_arm])
  {% else %}
    {% raise "Unsupported Linux architecture. Supported: x86_64, aarch64, arm" %}
  {% end %}
{% elsif flag?(:msvc) %}
  {% if flag?(:x86_64) %}
    process_platform(PLATFORM_CONFIG[:msvc_x64])
  {% elsif flag?(:i386) %}
    process_platform(PLATFORM_CONFIG[:msvc_x86])
  {% else %}
    {% raise "Unsupported MSVC architecture. Supported: x86_64, i386" %}
  {% end %}
{% elsif flag?(:win32) && flag?(:gnu) %}
  {% if flag?(:x86_64) %}
    process_platform(PLATFORM_CONFIG[:mingw_x64])
  {% elsif flag?(:i386) %}
    process_platform(PLATFORM_CONFIG[:mingw_x86])
  {% else %}
    {% raise "Unsupported MinGW architecture. Supported: x86_64, i386" %}
  {% end %}
  system(p("windres comctl32.rc -O coff -o comctl32.res"))
{% else %}
  {% raise "Unsupported platform. Supported: Darwin, Linux, MSVC, MinGW" %}
{% end %}

# Clean up temporary directory
if Dir.exists?(BUILD_DIR)
  FileUtils.rm_rf BUILD_DIR
end

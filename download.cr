require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "79761e2a-experimental"

ASSET_SHA256 = {
  "macOS-arm64-static-debug.zip"         => "036fece3a4f442134820768de69403cb13a9a63a18f48e2ea62b7613c934af4f",
  "macOS-arm64-static-release.zip"       => "4437b7079984afba57bd40f855ed6686535d8d8ee34a42c9fa9e2f623184176f",
  "macOS-x64-static-debug.zip"           => "3e04c97c1ea3f3d8fb4b25b789dc656fb9ce5684edfe4fb8881d080cb5370149",
  "macOS-x64-static-release.zip"         => "54155649543f14bb665709293fddc79c9ab9bb4645ab00f6d4e84389189bdf02",
  "Ubuntu-arm64-static-debug.zip"        => "f1597d85dad5e43940cadfdf9fbd08a380f6a616e4e1ac9054c53b7e1baeeb07",
  "Ubuntu-arm64-static-release.zip"      => "0d3a5b9959154dd00c4704ecfae56f6d5e0ea0803ac0baa74decc8435957fa60",
  "Ubuntu-x64-static-debug.zip"          => "cb09e2fde23c62fab0108173250ef275e108945c9678dc4a4ab85cc36ae8e9ca",
  "Ubuntu-x64-static-release.zip"        => "f2f9c7b08a792c3a7c2878ec550b99211bea3d769076b86f7ea29de27f2f71fa",
  "Windows-x64-mingw-static-debug.zip"   => "60c6602d1efb64ff1c9e89f59ce91c1692d3331516b8245a72a4b0501e2cf9b6",
  "Windows-x64-mingw-static-release.zip" => "4363f756109e3b921247ba44c66c06843da34887a1a22b33ae12cb36f54e6768",
  "Windows-x64-msvc-static-debug.zip"    => "a118786addcaf2eba09268802d7da2ea79619491b7ca8b255451fc38888bcdc3",
  "Windows-x64-msvc-static-release.zip"  => "70164632292b793000191612ecdf40c1ac119ba13e9fa220b43b59c489ec6209",
  "Windows-x64-ucrt-static-debug.zip"    => "2318449e6fdc85447e30774bd97c6d6f55abba740a43c95bf03e30b59190bcb1",
  "Windows-x64-ucrt-static-release.zip"  => "c53051cf32368e72a88c0c5f7a8b525f6e1ae76835d79985d6160a86c6923a19",
  "Windows-x86-msvc-static-debug.zip"    => "e98f7216df5f6e9dd32c6be11aa7c06f8f3c7d4e60e961092e18e0908f21f651",
  "Windows-x86-msvc-static-release.zip"  => "610308f3a0df4b15e9529497f6532374ef4a2b71dbb2598c761e8878aa0aa3e8",
}

# Path constants
PROJECT_DIR    = Dir.current
WORK_DIR       = File.tempname("uing-libui")
BUILD_DIR      = File.join(WORK_DIR, "builddir")
MESON_OUT_DIR  = "#{BUILD_DIR}/meson-out"
LIBUI_SOURCE   = "#{MESON_OUT_DIR}/libui.a"
PDB_SOURCE_DIR = "#{MESON_OUT_DIR}/libui.a.p"
DEBUG_DIR      = File.join(PROJECT_DIR, "libui/debug")
PDB_DEST_DIR   = "#{DEBUG_DIR}/libui.a.p"

Dir.mkdir(WORK_DIR)

def windows_flavor_from_msystem
  msystem = ENV["MSYSTEM"]?.to_s.upcase
  case msystem
  when "UCRT64"
    "ucrt"
  when "MINGW64"
    "mingw64"
  end
end

# Platform-specific configuration with architecture support
PLATFORM_CONFIG = {
  # macOS Intel x86_64
  darwin_x64: [
    {zip: "macOS-x64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "macOS-x64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # macOS Apple Silicon ARM64
  darwin_arm64: [
    {zip: "macOS-arm64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "macOS-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Linux x86_64
  linux_x64: [
    {zip: "Ubuntu-x64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "Ubuntu-x64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Linux ARM64
  linux_arm64: [
    {zip: "Ubuntu-arm64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "Ubuntu-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Windows MSVC x86_64
  msvc_x64: [
    {zip: "Windows-x64-msvc-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/ui.lib")},
    {zip: "Windows-x64-msvc-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/ui.lib"), extra_pdb: true},
  ],
  # Windows MSVC x86 32-bit
  msvc_x86: [
    {zip: "Windows-x86-msvc-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/ui.lib")},
    {zip: "Windows-x86-msvc-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/ui.lib"), extra_pdb: true},
  ],
  # Windows UCRT x86_64
  ucrt_x64: [
    {zip: "Windows-x64-ucrt-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "Windows-x64-ucrt-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Windows MinGW x86_64
  mingw_x64: [
    {zip: "Windows-x64-mingw-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "Windows-x64-mingw-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
}

# Low-level utility functions
def url_for_libui_ng_nightly(file_name)
  "https://github.com/kojix2/libui-ng/releases/download/commit-#{COMMIT_HASH}/#{file_name}"
end

def download_file(file_name, url)
  args = ["-fL", "-o", file_name, url]
  puts "Running: curl #{args.join(" ")}"
  process = Process.run("curl", args, output: STDOUT, error: STDERR)
  unless process.success? && File.exists?(file_name)
    raise "Failed to download #{file_name} from #{url}"
  end

  asset_name = File.basename(file_name)
  expected_sha256 = ASSET_SHA256[asset_name]? || raise "No SHA-256 checksum for #{asset_name}"
  actual_sha256 = Digest::SHA256.new.file(file_name).hexfinal
  unless actual_sha256 == expected_sha256
    raise "SHA-256 mismatch for #{asset_name}: expected #{expected_sha256}, got #{actual_sha256}"
  end
end

def normalize_zip_path(path)
  return if path.empty? || path.includes?('\0')
  normalized_separators = path.tr("\\", "/")
  return if normalized_separators.starts_with?("/") || normalized_separators.matches?(/\A[A-Za-z]:/)

  parts = [] of String
  normalized_separators.split('/').each do |part|
    next if part.empty? || part == "."

    if part == ".."
      return if parts.empty?
      parts.pop
    else
      parts << part
    end
  end

  return if parts.empty?
  parts.join("/")
end

def extract_zip_files(file_name, lib_path)
  return [] of String unless file_name.ends_with?(".zip")

  allowed_paths = lib_path.compact_map do |path|
    relative_path = Path[path].relative_to(Path[WORK_DIR]).to_s
    normalize_zip_path(relative_path)
  end
  extracted_paths = [] of String

  Compress::Zip::File.open(file_name) do |zip_file|
    zip_file.entries.each do |entry|
      entry_path = normalize_zip_path(entry.filename)
      next unless entry_path
      next unless allowed_paths.any? { |path| entry_path == path || entry_path.starts_with?(path + "/") }

      print "Extracting #{entry.filename} from #{file_name}..."

      # Preserve complete directory structure after normalizing the ZIP entry path.
      target_path = File.join(WORK_DIR, entry_path)
      FileUtils.mkdir_p(File.dirname(target_path)) unless entry.dir?

      unless entry.dir?
        entry.open do |io|
          File.open(target_path, "wb") do |file|
            IO.copy(io, file)
          end
        end
        extracted_paths << entry_path
      end
      puts "done"
    end
  end

  extracted_paths
end

def download_from_url(lib_path, file_name, url)
  puts "Downloading #{lib_path} from #{url}"

  download_file(file_name, url)
  extracted_paths = extract_zip_files(file_name, lib_path)
  missing_paths = lib_path.select do |path|
    relative_path = Path[path].relative_to(Path[WORK_DIR]).to_s
    !extracted_paths.includes?(relative_path) && !Dir.exists?(path)
  end
  unless missing_paths.empty?
    raise "#{file_name} did not contain expected entries: #{missing_paths.join(", ")}"
  end

  extracted_paths
ensure
  File.delete(file_name) if File.exists?(file_name)
end

# Mid-level functions
def download_libui_ng_nightly(lib_path, file_name)
  url = url_for_libui_ng_nightly(file_name)
  download_from_url(lib_path, File.join(WORK_DIR, file_name), url)
end

def download_and_place(zip_name : String, src : String, dest : String)
  FileUtils.rm_rf src if File.exists?(src)
  download_libui_ng_nightly([src], zip_name)
  FileUtils.mkdir_p File.dirname(dest)
  FileUtils.cp src, dest
end

def process_msvc_pdb_files(entry)
  FileUtils.rm_rf LIBUI_SOURCE if File.exists?(LIBUI_SOURCE)
  FileUtils.rm_rf PDB_SOURCE_DIR if Dir.exists?(PDB_SOURCE_DIR)
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
begin
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
  {% else %}
    {% raise "Unsupported Linux architecture. Supported: x86_64, aarch64" %}
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
  windows_flavor = windows_flavor_from_msystem
  {% if flag?(:x86_64) %}
    case windows_flavor
    when "ucrt"
      process_platform(PLATFORM_CONFIG[:ucrt_x64])
    else
      process_platform(PLATFORM_CONFIG[:mingw_x64])
    end
  {% elsif flag?(:i386) %}
    raise "MinGW x86 assets are not available"
  {% else %}
    {% raise "Unsupported MinGW architecture. Supported: x86_64" %}
  {% end %}
  windres_process = Process.run("windres", ["comctl32.rc", "-O", "coff", "-o", "comctl32.res"])
  unless windres_process.success?
    raise "windres failed to generate comctl32.res"
  end
  {% else %}
    {% raise "Unsupported platform. Supported: Darwin, Linux, MSVC, MinGW" %}
  {% end %}
ensure
  FileUtils.rm_rf(WORK_DIR)
end

require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "e497003b-experimental"

ASSET_SHA256 = {
  "macOS-arm64-static-debug.zip"         => "ee6fc00eec149e53401287dd5dedee8c6f0fde605035aba569ea98cb1d24dc5f",
  "macOS-arm64-static-release.zip"       => "5ea2ee09877f24cbce1676a863ecb58c0a872d31f584e7b30604afe493ddfc51",
  "macOS-x64-static-debug.zip"           => "d022944c850b5d3bb9015f605b30687a28be1c3767c1a461a5f66afec3710805",
  "macOS-x64-static-release.zip"         => "3c8637e1c960eb27f63d8701093600c2436fc493d255bfbd344c6bf43ed9bcc9",
  "Ubuntu-arm64-static-debug.zip"        => "cd3dff24e7981bd57a2f80a0753d495528cf226c7f5494449ad83a6666764394",
  "Ubuntu-arm64-static-release.zip"      => "990ef51bea23e9b49a15c4673ae03ba507f76cbfdfaa7a06a38bdf626459840f",
  "Ubuntu-x64-static-debug.zip"          => "9bc4108834141edbaac79492d03708f63a5b8ee9431330936852cd0e19ef86cf",
  "Ubuntu-x64-static-release.zip"        => "a88dbc713af036ec838846961ad827ede3bf93ac2e03fbeb0c2bbd6b143e2bfb",
  "Windows-x64-mingw-static-debug.zip"   => "fdab087060495667bed098e48915836499d246cffc82c5308578f43585f0b4ae",
  "Windows-x64-mingw-static-release.zip" => "b84e4ac4faeb5364cd5a6c0de20f7e33b4d62dc13aa20c1f8396ec26489a541b",
  "Windows-x64-msvc-static-debug.zip"    => "0e4d666264c4428726edb2e1b7869b30c9cf241dc483a514a04b391bb5823506",
  "Windows-x64-msvc-static-release.zip"  => "cfd217f727503b1876459f6371f25460ed371270c896865f706ec88f0bd748d9",
  "Windows-x64-ucrt-static-debug.zip"    => "4ccaca5ca0ffc0be4ff7b8ef1fae2cf5577e4e41db09c6c7e65affc1657b286a",
  "Windows-x64-ucrt-static-release.zip"  => "685719f9232a1a6610d2cd9eef457a5c3f89ceda17214e7f5c54fd08b174bf39",
  "Windows-x86-msvc-static-debug.zip"    => "f88be8609502d99fb3bd6950293f142abadb93911d5710c9561384bc2af75756",
  "Windows-x86-msvc-static-release.zip"  => "50279c07878cdb41168952e9e76ea77d4bf40662115d85e705ca431d98efc255",
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

def sha256_file(file_name)
  Digest::SHA256.new.file(file_name).hexfinal
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
  actual_sha256 = sha256_file(file_name)
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
    relative_path = normalize_zip_path(Path[path].relative_to(Path[WORK_DIR]).to_s)
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

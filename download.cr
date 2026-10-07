require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "5ccb6924-experimental"

ASSET_SHA256 = {
  "libui-ng-macos-arm64-static-debug.zip"           => "820d23f5d9f36daa2731d9a22a3c8ca7d25c4538005df19e4711122b2aa4799d",
  "libui-ng-macos-arm64-static-release.zip"         => "276dc8c4117adb2066b01bdc62caeee6da435ca4df35810e5934b6cc2a06a79d",
  "libui-ng-macos-x64-static-debug.zip"             => "5a6a75be6051c15ce14b671e3852f67c959f62b833a2a59e68e88f3472ab038e",
  "libui-ng-macos-x64-static-release.zip"           => "a1173d822576bc4dd3f9b8475dfcd36f5fbda9f3720f8268349f561c2dd48dbf",
  "libui-ng-ubuntu-arm64-static-debug.zip"          => "03908ef0575b3c4a9b0a13dbba0350887597d2cb264c4c9d38e6f9e07c283423",
  "libui-ng-ubuntu-arm64-static-release.zip"        => "201c00e32ef593f2058c51fe984607cfab65df23969f7f073be0e6aa35dbfa40",
  "libui-ng-ubuntu-x64-static-debug.zip"            => "4d21866229227bb084cc877bfbb3d34c8f52447fa894e56a49202062ffc874f1",
  "libui-ng-ubuntu-x64-static-release.zip"          => "88c54e5557f78e2c99ac0f11fed9d7942290be256bd70baa9410ee6428002c1a",
  "libui-ng-windows-x64-mingw-static-debug.zip"     => "11adec113d73d218ab461d9a654d5913f27a1c2ef43fa2fabe2683fc9d5e7910",
  "libui-ng-windows-x64-mingw-static-release.zip"   => "608aa3ce0512568182b1fa916912e2452b16112ba7e68e38ddc13b56867ae082",
  "libui-ng-windows-x64-msvc-static-md-debug.zip"   => "95690d9be1987a69b8bdd96ac009598ffa836583083ca961d28f85957177adfc",
  "libui-ng-windows-x64-msvc-static-md-release.zip" => "e9096401a5eccee1646602befcadd26668583e6824b7d39fe677ef678a6e1f62",
  "libui-ng-windows-x64-msvc-static-mt-debug.zip"   => "4e9b5f91a6d7882f829c7fe6a30547f76493112f8105e15b55adb79b86fddf16",
  "libui-ng-windows-x64-msvc-static-mt-release.zip" => "1aa5e836b2b21729aaf42eeb3724ba302f59fc13a75b29b1f1eb40a6172f01ef",
  "libui-ng-windows-x64-ucrt-static-debug.zip"      => "7640e38aed5fd9caac02ceee23e0c963ce89b7da6c17fa591f930a1b9e89f61f",
  "libui-ng-windows-x64-ucrt-static-release.zip"    => "8ccd3059408133b53e052741f33ab8911094a8a07e9e6aa7fd65650248d53d4c",
  "libui-ng-windows-x86-msvc-static-md-debug.zip"   => "17dd1c37d2a98afcd6cfb661d6148b87bd993eb61df791cdb273fd87accf6178",
  "libui-ng-windows-x86-msvc-static-md-release.zip" => "e62850df191285968417ea66ad0946568e988b398037f34443d65c2fbecb652b",
  "libui-ng-windows-x86-msvc-static-mt-debug.zip"   => "9556069847c85ffde84e9455e73c74c93d6c1036c6101629407ae977f4725156",
  "libui-ng-windows-x86-msvc-static-mt-release.zip" => "5ec9fab932cb4fa49be506b8c8dc4c552d31a6a63f58c5bec2ff60717444c6c0",
}

# Path constants
PROJECT_DIR       = Dir.current
WORK_DIR          = File.tempname("uing-libui")
SDK_LIB_DIR       = File.join(WORK_DIR, "lib")
LIBUI_SOURCE      = File.join(SDK_LIB_DIR, "libui.a")
MSVC_LIBUI_SOURCE = File.join(SDK_LIB_DIR, "libui.lib")
PDB_SOURCE        = File.join(SDK_LIB_DIR, "libui.pdb")

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
    {zip: "libui-ng-macos-x64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-macos-x64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # macOS Apple Silicon ARM64
  darwin_arm64: [
    {zip: "libui-ng-macos-arm64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-macos-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Linux x86_64
  linux_x64: [
    {zip: "libui-ng-ubuntu-x64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-ubuntu-x64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Linux ARM64
  linux_arm64: [
    {zip: "libui-ng-ubuntu-arm64-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-ubuntu-arm64-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Windows MSVC x86_64
  msvc_x64: [
    {zip: "libui-ng-windows-x64-msvc-static-md-release.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/md/ui.lib")},
    {zip: "libui-ng-windows-x64-msvc-static-md-debug.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/md/ui.lib"), extra_pdb: true},
    {zip: "libui-ng-windows-x64-msvc-static-mt-release.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/mt/ui.lib")},
    {zip: "libui-ng-windows-x64-msvc-static-mt-debug.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/mt/ui.lib"), extra_pdb: true},
  ],
  # Windows MSVC x86 32-bit
  msvc_x86: [
    {zip: "libui-ng-windows-x86-msvc-static-md-release.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/md/ui.lib")},
    {zip: "libui-ng-windows-x86-msvc-static-md-debug.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/md/ui.lib"), extra_pdb: true},
    {zip: "libui-ng-windows-x86-msvc-static-mt-release.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/mt/ui.lib")},
    {zip: "libui-ng-windows-x86-msvc-static-mt-debug.zip", src: MSVC_LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/mt/ui.lib"), extra_pdb: true},
  ],
  # Windows UCRT x86_64
  ucrt_x64: [
    {zip: "libui-ng-windows-x64-ucrt-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-windows-x64-ucrt-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
  ],
  # Windows MinGW x86_64
  mingw_x64: [
    {zip: "libui-ng-windows-x64-mingw-static-release.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/release/libui.a")},
    {zip: "libui-ng-windows-x64-mingw-static-debug.zip", src: LIBUI_SOURCE, dest: File.join(PROJECT_DIR, "libui/debug/libui.a")},
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
  asset_name = File.basename(file_name)
  expected_sha256 = ASSET_SHA256[asset_name]? || raise "No SHA-256 checksum for #{asset_name}"
  if expected_sha256 == "PENDING_RELEASE"
    raise "SHA-256 checksum for #{asset_name} is pending the corresponding libui-ng release"
  end

  args = ["-fL", "-o", file_name, url]
  puts "Running: curl #{args.join(" ")}"
  process = Process.run("curl", args, output: STDOUT, error: STDERR)
  unless process.success? && File.exists?(file_name)
    raise "Failed to download #{file_name} from #{url}"
  end

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
  FileUtils.rm_rf entry[:src] if File.exists?(entry[:src])
  FileUtils.rm_rf PDB_SOURCE if File.exists?(PDB_SOURCE)
  download_libui_ng_nightly([entry[:src], PDB_SOURCE], entry[:zip])
  FileUtils.mkdir_p File.dirname(entry[:dest])
  FileUtils.cp entry[:src], entry[:dest]

  # Keep the compile PDB next to ui.lib so the MSVC linker can find it.
  if File.exists?(PDB_SOURCE)
    FileUtils.cp PDB_SOURCE, File.dirname(entry[:dest])
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

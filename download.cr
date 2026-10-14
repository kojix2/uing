require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "d43d455d-experimental"

ASSET_SHA256 = {
  "libui-ng-macos-arm64-static-debug.zip"           => "13f658e1ac803cd596ff3ce234bd26af52c1190c67b8b0d425281a48332cb6d6",
  "libui-ng-macos-arm64-static-release.zip"         => "e0750cd073b89ce4c678fccbc771e9fbcf6a2b4c59f0f16e136136fa9c34dc6c",
  "libui-ng-macos-x64-static-debug.zip"             => "e84477157b414587dda5565034d8005967aa707578f3acc28e6b410a8b36f9c8",
  "libui-ng-macos-x64-static-release.zip"           => "d72875bcfc305e36de050f02d5a4153b66d5dd7e5bc3864d748e492b09f0f598",
  "libui-ng-ubuntu-arm64-static-debug.zip"          => "5672280cd739c0a4291b80e2ce1967d33f582383e4a08c8ab6002fd32dfa8602",
  "libui-ng-ubuntu-arm64-static-release.zip"        => "829160c949cc46fe19e9d771ae69011c6e23e865a07de8d923a83e2fedde3657",
  "libui-ng-ubuntu-x64-static-debug.zip"            => "d6d000d1f595476dc9c4e872bf4dae9f7c632f27679db38eba9f12e2fa48c67b",
  "libui-ng-ubuntu-x64-static-release.zip"          => "110061cb79de3b866b517607ed86d72f7cf992bc949079f513df9b81b2f67f8d",
  "libui-ng-windows-x64-mingw-static-debug.zip"     => "fbfec2ad91a112dbd7fa821830b4a27dfdc23cc1b5b1c43a4e25c795348da301",
  "libui-ng-windows-x64-mingw-static-release.zip"   => "e346c42042630d5cb9141f3eeae66defb76e122e08a3da41a9f4e62bec6a38be",
  "libui-ng-windows-x64-msvc-static-md-debug.zip"   => "eb0c3fe45daa4f89adb922b41330769ab7c23fb51b63efecc01f44ee481efd03",
  "libui-ng-windows-x64-msvc-static-md-release.zip" => "1c521707d22f44aec58e18b4cc6399aa3896c6f448bb9a6f5eaa5a5b36a8e783",
  "libui-ng-windows-x64-msvc-static-mt-debug.zip"   => "43873f0f31572c381e43e106253f1edaf085b4604f663b973e375a6bc6a813e9",
  "libui-ng-windows-x64-msvc-static-mt-release.zip" => "09af27bb754befce5fac11efababf0c79af793e4f72a0ad4b6398cb4cded56fe",
  "libui-ng-windows-x64-ucrt-static-debug.zip"      => "b6c8546409ee4572e0b5467fb939d6a4121dd146d2da23431926dd7306ee691d",
  "libui-ng-windows-x64-ucrt-static-release.zip"    => "9e0366302d91ee2adbfc7fbcbdaea6f433e261462764f738b0f7de69ea6cbf95",
  "libui-ng-windows-x86-msvc-static-md-debug.zip"   => "b6f7a427cf5af3114a57fb28adc8bf7fc317305c7fd500235a9fd341f312df13",
  "libui-ng-windows-x86-msvc-static-md-release.zip" => "34eb689b37cf607970c40d357aa739d90117f403129ef2a5c790a065f4bf8be8",
  "libui-ng-windows-x86-msvc-static-mt-debug.zip"   => "887a793fa09fd6164aa81e3f4183bc0b5b7fde821ae0e8945e8dffcc11f4a98c",
  "libui-ng-windows-x86-msvc-static-mt-release.zip" => "44b58e2e0ee0496458e9460f40d1459ad6954bcf4a38b7571b275b798cdebffd",
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

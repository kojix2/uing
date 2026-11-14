require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "5b20e239-experimental"

ASSET_SHA256 = {
  "libui-ng-macos-arm64-static-debug.zip"           => "94caf59ecb1affaf8e19faeae4e8ea03d33346bbd6585d6ccd44b2abfa72fc7d",
  "libui-ng-macos-arm64-static-release.zip"         => "524a9d649354ea23654391bf7720000b791cb5d55211d79e773276475a5d39b6",
  "libui-ng-macos-x64-static-debug.zip"             => "8e70ef1d6f0700c0d270011f4d3a01fdd4f79d4d36fd58022833db5c13a3a9a5",
  "libui-ng-macos-x64-static-release.zip"           => "815d59aeed018deb6e22082684dff2949b44c6c6494de126b0ee55a451e32351",
  "libui-ng-ubuntu-arm64-static-debug.zip"          => "2e3777279acbe43dd576c5c20cde324e4c1cf0371f6398eaf890f7ab5e7775e5",
  "libui-ng-ubuntu-arm64-static-release.zip"        => "d95f88fb56adb79334e8c72bf5a52e3e64c43fd9228726faf44584e14071f738",
  "libui-ng-ubuntu-x64-static-debug.zip"            => "0a9685b5ddb3392880bf8fcb766482fbfe9d38eb3eb99f1f679af7651a1c35a5",
  "libui-ng-ubuntu-x64-static-release.zip"          => "150e62ce70f635d969fc5c00ed9c543c1a75985a96231c78ac0bb23ee30b109a",
  "libui-ng-windows-x64-msvc-static-md-debug.zip"   => "d22a7b07444bd8040e8d6c9a802d3705e3b405c36d0ae997617459c888da5c40",
  "libui-ng-windows-x64-msvc-static-md-release.zip" => "dc0f7b398f3ada21c90da5cb98ccfa11401402848e555e2b9d013c07b0dbb56f",
  "libui-ng-windows-x64-msvc-static-mt-debug.zip"   => "2caa05fb6450f2e53621b8f373eaa10b54a5f6a7f26b8bb172c5cf30f8639bd0",
  "libui-ng-windows-x64-msvc-static-mt-release.zip" => "0b415d103493df91898960ed4392620c10fdb517f99a95283b4a36ca9fab55b3",
  "libui-ng-windows-x64-ucrt-static-debug.zip"      => "dadf19aa8df298fc56af1c33a25f8591b1680625fedcb2239d38aafd120d6808",
  "libui-ng-windows-x64-ucrt-static-release.zip"    => "5641ce4bd8c02f8c09b9a951d4a5a061c8b8bb5971b47115f224e089f9931ef8",
  "libui-ng-windows-x86-msvc-static-md-debug.zip"   => "65fbe80dbb1316d5771845b9c721fe5b40f3350eed7b5e3bb2509055f0ad9ca6",
  "libui-ng-windows-x86-msvc-static-md-release.zip" => "f326340c0e6cf89777c3f48871de9b5f754e13aa766c711a06ff995a95dc22bd",
  "libui-ng-windows-x86-msvc-static-mt-debug.zip"   => "2dd0c18b2c690fa5fe821c2faa38826411ac52ba092a59e9cef8982a0992cec1",
  "libui-ng-windows-x86-msvc-static-mt-release.zip" => "5ff0b388860fc8e0e920a0c19dd5d6f0e4989180293ef3e18deae295e698f5fc",
}

# Path constants
PROJECT_DIR       = Dir.current
WORK_DIR          = File.tempname("uing-libui")
SDK_LIB_DIR       = File.join(WORK_DIR, "lib")
LIBUI_SOURCE      = File.join(SDK_LIB_DIR, "libui.a")
MSVC_LIBUI_SOURCE = File.join(SDK_LIB_DIR, "libui.lib")
PDB_SOURCE        = File.join(SDK_LIB_DIR, "libui.pdb")

Dir.mkdir(WORK_DIR)

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
  {% if flag?(:x86_64) %}
    unless ENV["MSYSTEM"]?.to_s.upcase == "UCRT64"
      raise "Unsupported MSYS2 environment: #{ENV["MSYSTEM"]?}. Use UCRT64."
    end
    process_platform(PLATFORM_CONFIG[:ucrt_x64])
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

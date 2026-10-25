require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "dd9eb7ec-experimental"

ASSET_SHA256 = {
  "libui-ng-macos-arm64-static-debug.zip"           => "7ab1b4211262c136f6e386ad89a80d1c4bed53ddf7cf0e846f6ed41c409b826e",
  "libui-ng-macos-arm64-static-release.zip"         => "797aeacff05e86d73a7311d03720cc2f17b9afe428404538f61edd804ee4bb61",
  "libui-ng-macos-x64-static-debug.zip"             => "6163d8a39fe244471f1c67dea7262cb95cd0f7549127a5ac9a6f185bffe864b6",
  "libui-ng-macos-x64-static-release.zip"           => "3f18720ed87bace0c26df5dfebdc903a6ba2fc3ca5c38d8071ecbf8a938e2759",
  "libui-ng-ubuntu-arm64-static-debug.zip"          => "9dc764a3d45da153fa461666e57ee94417e47bc1baaafcfc6ddb2de91065902f",
  "libui-ng-ubuntu-arm64-static-release.zip"        => "c3fb756007533eff749d6baf345f9a85bb8be3e9664769c1e95c142bd4e08aa0",
  "libui-ng-ubuntu-x64-static-debug.zip"            => "b0033c4f9318c93a36e05aebc88c54b1c96ed78a2a69713b5ea0c5b49bc7fdbc",
  "libui-ng-ubuntu-x64-static-release.zip"          => "71c46f85303d1c67e5b9f6510ec1b0252fb9031b337200f706f31785bad18178",
  "libui-ng-windows-x64-msvc-static-md-debug.zip"   => "05aeb902b176ee0b1e068ef0bdc327511723c0d396396c7ef7f724e8dd0c2ad8",
  "libui-ng-windows-x64-msvc-static-md-release.zip" => "e27b01c1870cee82b5456a2d3696af5ba4ebbc0695647fa307ad6934ac51a1e4",
  "libui-ng-windows-x64-msvc-static-mt-debug.zip"   => "fcc0660056aa401e28dcace4db9b23939e54d7fffae3e47d65f6c6338318182c",
  "libui-ng-windows-x64-msvc-static-mt-release.zip" => "1556d8341af387a476a871b22bbe445e4dc7a77d61252539f041c41d71460bef",
  "libui-ng-windows-x64-ucrt-static-debug.zip"      => "9d0991af975d35cea1de0c5c0aca6bd5637bfb92d829d4d2cb6c2031b23a1b3e",
  "libui-ng-windows-x64-ucrt-static-release.zip"    => "f327e59955ef5f16529235634fc6f7779cff0882f7812da2faa5d72f1a81c883",
  "libui-ng-windows-x86-msvc-static-md-debug.zip"   => "00e2b1d717c196cf17e9db847894ac6574f88371956a9a92c9135dc9b0c287b3",
  "libui-ng-windows-x86-msvc-static-md-release.zip" => "28747eba32c77accced079a82c1c3023aeba75f774b8a537b53fe7deff30bd02",
  "libui-ng-windows-x86-msvc-static-mt-debug.zip"   => "4df8a196471c06dd6f6cd1e3cfa3ae7b9acdca9ad3003bc3144e1b5bc6d19c8f",
  "libui-ng-windows-x86-msvc-static-mt-release.zip" => "ff527b16fe257c8f9fcbd30c6a4322b4ff79c1cc6c86fb288b84a9e7a0250fa2",
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

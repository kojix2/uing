require "compress/zip"
require "digest/sha256"
require "file/tempfile"
require "file_utils"

COMMIT_HASH = "e88d1af4-experimental"

ASSET_SHA256 = {
  "libui-ng-macos-arm64-static-debug.zip"           => "9b9c687ad0819f307261f853b39dacf2bd6f8f5d6cbeb8bc719daf11d9513689",
  "libui-ng-macos-arm64-static-release.zip"         => "0f94648424a82f6c501490e592c06e790d7f702d9d1fa8e86ed1c66e0b632d60",
  "libui-ng-macos-x64-static-debug.zip"             => "d781bd364a4d8c475eeef9563427980b01a5b9529c547585f97563259e7fcb99",
  "libui-ng-macos-x64-static-release.zip"           => "71bacbb156aaea00b56b5bd2ddd9828007d2891d1495060802d35734c0492a23",
  "libui-ng-ubuntu-arm64-static-debug.zip"          => "a4515c94358d81dd365ad802bb4978eae0dff867981828fd7ad5d2585ad2791c",
  "libui-ng-ubuntu-arm64-static-release.zip"        => "120e61a16d8fd6fab4fbd2f9573c8bead32765697b17a7819b7a44dcefbc6e1c",
  "libui-ng-ubuntu-x64-static-debug.zip"            => "f9a93d55feed5ec1d0e0566d5cd5b02bcadfbee43a4d43618f9883599c5e920a",
  "libui-ng-ubuntu-x64-static-release.zip"          => "4d750cd129a40a0b25d3ac3def9f4d1cc05b8330759713d7217c83d4e51d0ad0",
  "libui-ng-windows-x64-mingw-static-debug.zip"     => "e25d3af83402d6b9e4916a3e80a303f4620b4c091f7a001219154acd442ef49e",
  "libui-ng-windows-x64-mingw-static-release.zip"   => "1621a67da3256e223f19702b6d5ec743d47446bb13a51da42ba6606589134fb4",
  "libui-ng-windows-x64-msvc-static-md-debug.zip"   => "8fcf06d66feb4c66a14ee0d903a5c287b02ceb797ffebc7681f6e7f56d99b795",
  "libui-ng-windows-x64-msvc-static-md-release.zip" => "650479c347d7e3445ea6ef0dbceb2e6ad0d9b0c4884d97c0fd41a1ce123021ed",
  "libui-ng-windows-x64-msvc-static-mt-debug.zip"   => "b16acdac4e91a897859229eb512b7d3fabfb0672dc2cd064e4c562e8710e3fc2",
  "libui-ng-windows-x64-msvc-static-mt-release.zip" => "a79c749b5211b01128e8ea4a0227bfebc3618698a1b56a925eefac4dd6b4c464",
  "libui-ng-windows-x64-ucrt-static-debug.zip"      => "d921777bcc27be61ce6dbd888e6b10c3fdeba74dc33c9c007cd5cba815c2adf5",
  "libui-ng-windows-x64-ucrt-static-release.zip"    => "845a27d362bc07a46d834d0142d30aaa1392527d06c06f3f217d57f03b0c37e8",
  "libui-ng-windows-x86-msvc-static-md-debug.zip"   => "8593864c13d2498f67062556b6fe497eb284261a24c1717905702a5209211c75",
  "libui-ng-windows-x86-msvc-static-md-release.zip" => "cb31f73c67c230aa4a16d1d39cb6da176b4ce192d9f0eb3c216a0f1d3b687435",
  "libui-ng-windows-x86-msvc-static-mt-debug.zip"   => "07f3fc2561f169d14e94a131542e5246ed5fc32ac5096be67d505a86ef2b5695",
  "libui-ng-windows-x86-msvc-static-mt-release.zip" => "cb7e06c95b651e8a1b0145f08c9491080e1bc458a8eb3b32a276716cc95e009e",
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

require "json"

REPOSITORY    = "kojix2/libui-ng"
DOWNLOAD_PATH = File.expand_path("../download.cr", __DIR__)

def usage : NoReturn
  abort "Usage: crystal run scripts/update_libui_ng.cr -- <commit-hash[-experimental]>"
end

usage unless ARGV.size == 1

release_id = ARGV[0]
release_tag = release_id.starts_with?("commit-") ? release_id : "commit-#{release_id}"
commit_hash = release_tag.lchop("commit-")

source = File.read(DOWNLOAD_PATH)
newline = source.includes?("\r\n") ? "\r\n" : "\n"
asset_names = [] of String
source.scan(/zip:\s*"([^"]+\.zip)"/) do |match|
  asset_names << match[1]
end
asset_names = asset_names.uniq.sort_by!(&.downcase)
abort "No configured ZIP assets found in #{DOWNLOAD_PATH}" if asset_names.empty?

output = IO::Memory.new
error = IO::Memory.new
status = Process.run(
  "gh",
  ["api", "repos/#{REPOSITORY}/releases/tags/#{release_tag}"],
  output: output,
  error: error
)
abort "Failed to fetch #{release_tag}: #{error}" unless status.success?

release = JSON.parse(output.to_s).as_h
actual_tag = release["tag_name"].as_s
abort "Requested #{release_tag}, but GitHub returned #{actual_tag}" unless actual_tag == release_tag

digests = {} of String => String
release["assets"].as_a.each do |asset|
  fields = asset.as_h
  name = fields["name"].as_s
  next unless asset_names.includes?(name)
  abort "Duplicate release asset: #{name}" if digests.has_key?(name)

  digest = fields["digest"]?.try(&.as_s?)
  match = digest.try { |value| /\Asha256:([0-9a-fA-F]{64})\z/.match(value) }
  abort "Missing or invalid SHA-256 digest for #{name}" unless match
  digests[name] = match[1].downcase
end

missing = asset_names.reject { |name| digests.has_key?(name) }
abort "Release is missing configured assets: #{missing.join(", ")}" unless missing.empty?

longest_name = asset_names.max_of(&.size)
checksum_lines = asset_names.map do |name|
  padding = " " * (longest_name - name.size + 1)
  %(  "#{name}"#{padding}=> "#{digests[name]}",)
end

generated = <<-CRYSTAL
  COMMIT_HASH = "#{commit_hash}"

  ASSET_SHA256 = {
  #{checksum_lines.join("\n")}
  }
  CRYSTAL
generated = generated.gsub("\n", newline) if newline == "\r\n"

block_start = source.index("COMMIT_HASH = ") || abort "COMMIT_HASH not found in #{DOWNLOAD_PATH}"
checksum_start = source.index("ASSET_SHA256 = {", block_start) || abort "ASSET_SHA256 not found in #{DOWNLOAD_PATH}"
checksum_end = source.index("#{newline}}#{newline}", checksum_start) || abort "End of ASSET_SHA256 not found in #{DOWNLOAD_PATH}"
block_end = checksum_end + newline.size + 1
updated = source[0...block_start] + generated + source[block_end..]

if updated == source
  puts "#{release_tag} is already current"
  exit
end

temporary_path = "#{DOWNLOAD_PATH}.tmp"
begin
  File.write(temporary_path, updated)
  File.rename(temporary_path, DOWNLOAD_PATH)
ensure
  File.delete(temporary_path) if File.exists?(temporary_path)
end

immutable = release["immutable"]?.try(&.as_bool?) || false
puts "Updated #{DOWNLOAD_PATH} from #{release_tag} (immutable: #{immutable})"

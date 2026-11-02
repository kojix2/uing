module UIng
  VERSION = {{ read_file("#{__DIR__}/../../shard.yml").match(/^version:[ \t]*(\S+)/m)[1] }}
  SOURCE  = "https://github.com/kojix2/uing"
end

require "../spec_helper"

describe UIng do
  it "reports the linked libui-ng version" do
    UIng.libui_version.should match(/\A(?:(?:commit-[0-9a-f]+(?:-experimental)?|[0-9a-f]+)(?:-dirty)?|unknown)\z/)
  end

  it "uninitializes UIng when its init block raises" do
    output = IO::Memory.new
    error = IO::Memory.new
    program = File.expand_path("../programs/init_block_cleanup.cr", __DIR__)
    status = Process.run(ENV["CRYSTAL"]? || "crystal", ["run", program], output: output, error: error)

    status.success?.should be_true, "#{output}\n#{error}"
  end

  it "does not invoke native shutdown when the runtime is already inactive" do
    UIng.uninit
    UIng.uninit
  end
end

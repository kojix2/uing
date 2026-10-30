require "../spec_helper"

describe UIng do
  it "uninitializes UIng when its init block raises" do
    output = IO::Memory.new
    error = IO::Memory.new
    fixture = File.expand_path("../fixtures/init_block_cleanup.cr", __DIR__)
    status = Process.run(ENV["CRYSTAL"]? || "crystal", ["run", fixture], output: output, error: error)

    status.success?.should be_true, "#{output}\n#{error}"
  end

  it "does not invoke native shutdown when the runtime is already inactive" do
    UIng.uninit
    UIng.uninit
  end
end

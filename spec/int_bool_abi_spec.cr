require "./spec_helper"

describe "native integer boolean ABI" do
  it "preserves full C int values in calls and callbacks" do
    source = File.join(__DIR__, "fixtures", "int_bool_abi.c")
    fixture = File.join(__DIR__, "fixtures", "int_bool_abi.cr")
    object = File.join(
      Dir.tempdir,
      {% if flag?(:msvc) %}
        "uing-int-bool-abi-#{Process.pid}.obj"
      {% else %}
        "uing-int-bool-abi-#{Process.pid}.o"
      {% end %}
    )
    output = IO::Memory.new
    error = IO::Memory.new

    compiler, compile_args = {% if flag?(:msvc) %}
                               {ENV["CC"]? || "cl", ["/nologo", "/c", source, "/Fo#{object}"]}
                             {% else %}
                               {ENV["CC"]? || "cc", ["-c", source, "-o", object]}
                             {% end %}

    begin
      compile_status = Process.run(compiler, compile_args, output: output, error: error)
      compile_status.success?.should be_true, "#{output}\n#{error}"

      run_status = Process.run(ENV["CRYSTAL"]? || "crystal", ["run", fixture, "--link-flags", object], output: output, error: error)
      run_status.success?.should be_true, "#{output}\n#{error}"
    ensure
      File.delete(object) if File.exists?(object)
    end
  end
end

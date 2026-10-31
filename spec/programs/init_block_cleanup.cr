require "../../src/uing"

# Keep these replacements in a dedicated process: redefining UIng.init/uninit
# in the main spec binary would disable real native initialization for every
# other spec loaded into that process.
module UIng
  @@init_calls_for_spec = 0
  @@uninit_calls_for_spec = 0

  def self.init : Nil
    @@init_calls_for_spec += 1
  end

  def self.uninit : Nil
    @@uninit_calls_for_spec += 1
  end

  def self.lifecycle_calls_for_spec : {Int32, Int32}
    {@@init_calls_for_spec, @@uninit_calls_for_spec}
  end
end

begin
  UIng.init { raise "boom" }
rescue exception
  raise exception unless exception.message == "boom"
end

raise "unexpected init/uninit calls: #{UIng.lifecycle_calls_for_spec}" unless UIng.lifecycle_calls_for_spec == {1, 1}

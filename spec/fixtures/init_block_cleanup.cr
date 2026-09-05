require "../../src/uing"

# Keep these replacements in a dedicated process: redefining UIng.init/uninit
# in the main spec binary would disable real native initialization for every
# other spec loaded into that process.
module UIng
  @@fixture_init_calls = 0
  @@fixture_uninit_calls = 0

  def self.init : Nil
    @@fixture_init_calls += 1
  end

  def self.uninit : Nil
    @@fixture_uninit_calls += 1
  end

  def self.fixture_calls : {Int32, Int32}
    {@@fixture_init_calls, @@fixture_uninit_calls}
  end
end

begin
  UIng.init { raise "boom" }
rescue exception
  raise exception unless exception.message == "boom"
end

raise "unexpected init/uninit calls: #{UIng.fixture_calls}" unless UIng.fixture_calls == {1, 1}

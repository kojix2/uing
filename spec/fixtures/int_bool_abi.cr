lib IntBoolABI
  fun round_trip = uing_abi_round_trip(value : LibC::Int) : LibC::Int
  fun call = uing_abi_call(callback : (Pointer(Void) -> LibC::Int), data : Pointer(Void)) : LibC::Int
end

{0, 1, 2, 256, -1}.each do |value|
  actual = IntBoolABI.round_trip(value)
  raise "integer ABI mismatch: #{value} became #{actual}" unless actual == value
  raise "boolean conversion mismatch for #{value}" unless (actual != 0) == (value != 0)
end

callback = ->(_data : Pointer(Void)) : LibC::Int { 256 }
raise "callback ABI mismatch" unless IntBoolABI.call(callback, Pointer(Void).null) == 256

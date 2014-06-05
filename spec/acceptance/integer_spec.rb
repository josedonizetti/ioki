require 'spec_helper'

describe Ioki::Emitter do
  it "should compile basic integers" do
    integers = [0, 1, -1, 10, -10, 2736, -2736, 536870911, -536870912]
    integers.each do |integer|
      emitter = Ioki::Emitter.new("test.s")
      emitter.emit_program(integer)
      result = `sh compile.sh`.chomp

      expect(result).to eq(integer.to_s)
      emitter.clean
    end
  end
end

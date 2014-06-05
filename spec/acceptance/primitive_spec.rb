require 'spec_helper'

describe Ioki::Emitter do
  it "should compile primitives with one argument" do

    primitives = {
      "(fxadd1 0)" => "1",
      "(fxadd1 -1)" => "0",
      "(fxadd1 1)" => "2",
      "(fxadd1 -100)" => "-99",
      "(fxadd1 1000)" => "1001",
      "(fxadd1 536870910)" => "536870911",
      "(fxadd1 -536870912)" => "-536870911"
    }
    #"(fxadd1 (fxadd1 0))" => "2"
    #"(fxadd1 (fxadd1 (fxadd1 (fxadd1 (fxadd1 (fxadd1 12))))))" => "18"
    primitives.each do |code, expected|
      emitter = Ioki::Emitter.new("test.s")
      emitter.emit_program(code)
      result = `sh compile.sh`.chomp
      emitter.clean
      expect(result).to eq(expected)
    end
  end
end

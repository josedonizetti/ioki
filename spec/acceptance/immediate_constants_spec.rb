require 'spec_helper'

describe Ioki::Emitter do
  it "should compile basic immediate constants" do
    immediates =
      [ "#f", "#t", "()", "!", "#", "$", "%", "&", "'", "(",
        ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3",
        "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">",
        "?", "@", "A", "B", "C","D", "E", "F", "G", "H", "I",
        "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z", "[", "]", "^", "_", "`",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
        "l", "m", "n", "o",  "p", "q", "r", "s", "t", "u", "v",
        "w", "x", "y", "z", "{", "|", "}", "~" ]

    immediates.each do |immediate|
      emitter = Ioki::Emitter.new("test.s")
      emitter.emit_program(immediate)

      result = `sh compile.sh`.chomp

      emitter.clean
      expect(result).to eq(immediate)
    end
  end
  
end

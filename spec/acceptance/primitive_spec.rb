require 'spec_helper'

describe Ioki::Emitter do
  it "should compile fxadd1" do

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

  it "should compile fixnum->char" do
    primitives = {
      "(fixnum->char 65)" => "A",
      "(fixnum->char 97)" => "a",
      "(fixnum->char 122)" => "z",
      "(fixnum->char 90)" => "Z",
      "(fixnum->char 48)" => "0",
      "(fixnum->char 57)" => "9",
      "(char->fixnum #\\A)" => "65",
      "(char->fixnum #\\a)" => "97",
      "(char->fixnum #\\z)" => "122",
      "(char->fixnum #\\Z)" => "90",
      "(char->fixnum #\\0)" => "48",
      "(char->fixnum #\\9)" => "57",
    }

    #[($char->fixnum ($fixnum->char 12)) => "12\n"]
    #[($fixnum->char ($char->fixnum #\x)) => "#\\x\n"]
    primitives.each do |code, expected|
      emitter = Ioki::Emitter.new("test.s")
      emitter.emit_program(code)
      result = `sh compile.sh`.chomp
      emitter.clean
      expect(result).to eq(expected)
    end
  end

  it "should compile char->fixnum" do
    primitives = {
      "(char->fixnum #\\A)" => "65",
      "(char->fixnum #\\a)" => "97",
      "(char->fixnum #\\z)" => "122",
      "(char->fixnum #\\Z)" => "90",
      "(char->fixnum #\\0)" => "48",
      "(char->fixnum #\\9)" => "57",
    }

    #[($char->fixnum ($fixnum->char 12)) => "12\n"]
    #[($fixnum->char ($char->fixnum #\x)) => "#\\x\n"]
    primitives.each do |code, expected|
      emitter = Ioki::Emitter.new("test.s")
      emitter.emit_program(code)
      result = `sh compile.sh`.chomp
      emitter.clean
      expect(result).to eq(expected)
    end
  end

end

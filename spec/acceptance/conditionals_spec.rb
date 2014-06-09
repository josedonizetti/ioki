require 'spec_helper'

describe "Conditionals" do
  it "should compile if expressions" do
    expressions = {
      "(if #t 12 13)" => "12",
      "(if #f 12 13)" => "13",
      "(if 0 12 13)"  => "12",
      "(if () 43 ())" => "43",
      "(if #t (if 12 13 4) 17)" => "13",
      "(if #f 12 (if #f 13 4))" => "4",
      "(if #\\X (if 1 2 3) (if 4 5 6))" => "2",
      "(if (not (boolean? #t)) 15 (boolean? #f))" => "#t",
      "(if (if (char? #\\a) (boolean? #\\b) (fixnum? #\\c)) 119 -23)" => "-23",
      "(if (if (if (not 1) (not 2) (not 3)) 4 5) 6 7)" => "6",
      "(if (not (if (if (not 1) (not 2) (not 3)) 4 5)) 6 7)" => "7",
      "(not (if (not (if (if (not 1) (not 2) (not 3)) 4 5)) 6 7))" => "#f",
      "(if (char? 12) 13 14)" => "14",
      "(if (char? #\\a) 13 14)" => "13",
      "(fxadd1 (if (fxsub1 1) (fxsub1 13) 14))" => "13",
    }

    expressions.each do |code, expected|
      got = compile_and_execute_test(code)
      expect(got).to eq(expected)
    end
  end
end

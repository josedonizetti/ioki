require 'spec_helper'

describe "Conditionals" do

  shared_examples_for "a form" do
    it "should compile and execute" do
      forms.each do |code, expected|
        got = compile_and_execute_test(code)
        expect(got).to eq(expected)
      end
    end
  end

  describe "if" do
    let(:forms) {{
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
    }}

    it_behaves_like "a form"
  end

  describe "and" do
    let(:forms) {{
      "(and #t)" => "#t",
      "(and #f)" => "#f",
      "(and #t #t)" => "#t",
      "(and #f #f)" => "#f",
      "(and (and 1 #t) #f)" => "#f",
      "(and #f #t)" => "#f",
      "(and (and 0 1 2 3) 1)" => "1",
      "(and 0 #f 1)" => "#f",
      "(and #f #t 1)" => "#f",
      "(and 0 1 2 3 4 5 #t)" => "#t",
      "(and #t 0 1 2 3 4 5)" => "5",
    }}

    it_behaves_like "a form"
  end

  describe "or" do
    let(:forms) {{
      "(or #t)" => "#t",
      "(or #f)" => "#f",
      "(or #t #t)" => "#t",
      "(or (and #t) #f)" => "#t",
      "(or (or 1 #f #t) #f)" => "1",
      "(or #f #t)" => "#t",
      "(or 0 1)" => "0",
      "(or 0 #f 1)" => "0",
      "(or #f #t 1)" => "#t",
      "(or 0 1 2 3 4 5 #t)" => "0",
      "(or #t 0 1 2 3 4 5)" => "#t",
    }}

    it_behaves_like "a form"
  end

end

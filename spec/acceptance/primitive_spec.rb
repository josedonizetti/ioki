require 'spec_helper'

describe Ioki::Emitter do

  shared_examples_for "a primitive" do
    it "should compile and execute" do
      primitives.each do |code, expected|
        got = compile_and_execute_test(code)
        expect(got).to eq(expected)
      end
    end
  end

  describe "fxadd1" do
    let(:primitives) {{
      "(fxadd1 0)" => "1",
      "(fxadd1 -1)" => "0",
      "(fxadd1 1)" => "2",
      "(fxadd1 -100)" => "-99",
      "(fxadd1 1000)" => "1001",
      "(fxadd1 536870910)" => "536870911",
      "(fxadd1 -536870912)" => "-536870911",
      "(fxadd1 (fxadd1 0))" => "2",
      "(fxadd1 (fxadd1 (fxadd1 (fxadd1 (fxadd1 (fxadd1 12))))))" => "18"
    }}

    it_behaves_like "a primitive"
  end

  describe "fxsub1" do
    let(:primitives) {{
      "(fxsub1 0)" => "-1",
      "(fxsub1 -1)" => "-2",
      "(fxsub1 1)" => "0",
      "(fxsub1 -100)" => "-101",
      "(fxsub1 1000)" => "999",
      "(fxsub1 536870910)" => "536870909",
      "(fxsub1 -536870911)" => "-536870912",
      "(fxsub1 (fxsub1 0))" => "-2",
      "(fxsub1 (fxsub1 (fxsub1 (fxsub1 (fxsub1 (fxsub1 12))))))" => "6"
    }}

    it_behaves_like "a primitive"
  end

  describe "fixnum->char" do
    let(:primitives) {{
      "(fixnum->char 65)" => "#\\A",
      "(fixnum->char 97)" => "#\\a",
      "(fixnum->char 122)" => "#\\z",
      "(fixnum->char 90)" => "#\\Z",
      "(fixnum->char 48)" => "#\\0",
      "(fixnum->char 57)" => "#\\9",
      "(char->fixnum #\\A)" => "65",
      "(char->fixnum #\\a)" => "97",
      "(char->fixnum #\\z)" => "122",
      "(char->fixnum #\\Z)" => "90",
      "(char->fixnum #\\0)" => "48",
      "(char->fixnum #\\9)" => "57",
      "(char->fixnum (fixnum->char 12))" => "12",
      "(fixnum->char (char->fixnum #\\x))" => "#\\x"
    }}

    it_behaves_like "a primitive"
  end

  describe "char->fixnum" do
    let(:primitives) {{
      "(char->fixnum #\\A)" => "65",
      "(char->fixnum #\\a)" => "97",
      "(char->fixnum #\\z)" => "122",
      "(char->fixnum #\\Z)" => "90",
      "(char->fixnum #\\0)" => "48",
      "(char->fixnum #\\9)" => "57",
      "(char->fixnum (fixnum->char 12))" => "12",
      "(fixnum->char (char->fixnum #\\x))" => "#\\x"
    }}

    it_behaves_like "a primitive"
  end

  describe "fixnum?" do
     let(:primitives) {{
       "(fixnum? 0)" => "#t",
       "(fixnum? 1)" => "#t",
       "(fixnum? -1)" => "#t",
       "(fixnum? 37287)" => "#t",
       "(fixnum? -23873)" => "#t",
       "(fixnum? 536870911)" => "#t",
       "(fixnum? -536870912)" => "#t",
       "(fixnum? #t)" => "#f",
       "(fixnum? #f)" => "#f",
       "(fixnum? ())" => "#f",
       "(fixnum? #\\Q)" => "#f",
       "(fixnum? (fixnum? 12))" => "#f",
       "(fixnum? (fixnum? #f))" => "#f",
       "(fixnum? (fixnum? #\\A))" => "#f",
       "(fixnum? (char->fixnum #\\r))" => "#t",
       "(fixnum? (fixnum->char 12))" => "#f",
     }}

     it_behaves_like "a primitive"
  end

  describe "fxzero?" do
    let(:primitives) {{
      "(fxzero? 0)" => "#t",
      "(fxzero? 1)" => "#f",
      "(fxzero? -1)" => "#f"
    }}

    it_behaves_like "a primitive"
  end

  describe "null?" do
    let(:primitives) {{
     "(null? ())" => "#t",
     "(null? #f)" => "#f",
     "(null? #t)" => "#f",
     "(null? (null? ()))" => "#f",
     "(null? #\\a)" => "#f",
     "(null? 0)" => "#f",
     "(null? -10)" => "#f",
     "(null? 10)" => "#f"
    }}

    it_behaves_like "a primitive"
  end

  describe "boolean?" do
    let(:primitives) {{
      "(boolean? #t)" => "#t",
      "(boolean? #f)" => "#t",
      "(boolean? 0)" => "#f",
      "(boolean? 1)" => "#f",
      "(boolean? -1)" => "#f",
      "(boolean? ())" => "#f",
      "(boolean? #\\a)" => "#f",
      "(boolean? (boolean? 0))" => "#t",
      "(boolean? (fixnum? (boolean? 0)))" => "#t"
    }}

    it_behaves_like "a primitive"
  end

  describe "char?" do
    let(:primitives) {{
      "(char? #\\a)" => "#t",
      "(char? #\\Z)" => "#t",
      "(char? #\\newline)" => "#t",
      "(char? #t)" => "#f",
      "(char? #f)" => "#f",
      "(char? ())" => "#f",
      "(char? 0)" => "#f",
      "(char? 23870)" => "#f",
      "(char? -23789)" => "#f",
      "(char? (char? #t))" => "#f"
    }}

    it_behaves_like "a primitive"
  end

  describe "not" do
    let(:primitives) {{
      "(not #t)" => "#f",
      "(not #f)" => "#t",
      "(not 15)" => "#f",
      "(not ())" => "#f",
      "(not #\\A)" => "#f",
      "(not (not #t))" => "#t",
      "(not (not #f))" => "#f",
      "(not (not 15))" => "#t",
      "(not (fixnum? 15))" => "#f",
      "(not (fixnum? #f))" => "#t"
    }}

    it_behaves_like "a primitive"
  end

  describe "fxlognot" do
    let(:primitives) {{
      "(fxlognot 0)" => "-1",
      "(fxlognot -1)" => "0",
      "(fxlognot 1)" => "-2",
      "(fxlognot -2)" => "1",
      "(fxlognot 536870911)" => "-536870912",
      "(fxlognot -536870912)" => "536870911",
      "(fxlognot (fxlognot 237463))" => "237463"
    }}

    it_behaves_like "a primitive"
  end

  describe "and" do
    let(:primitives) {{
      "(and #t)" => "#t",
      "(and #f)" => "#f",
      "(and #t #t)" => "#t",
      "(and #f #f)" => "#f",
      "(and #t #f)" => "#f",
      "(and #f #t)" => "#f",
      "(and 0 1)" => "1",
      "(and 0 #f 1)" => "#f",
      "(and #f #t 1)" => "#f",
      "(and 0 1 2 3 4 5 #t)" => "#t",
      "(and #t 0 1 2 3 4 5)" => "5",
    }}

    it_behaves_like "a primitive"
  end

  describe "or" do
    let(:primitives) {{
      "(or #t)" => "#t",
      "(or #f)" => "#f",
      "(or #t #t)" => "#t",
      "(or #f #f)" => "#f",
      "(or #t #f)" => "#t",
      "(or #f #t)" => "#t",
      "(or 0 1)" => "0",
      "(or 0 #f 1)" => "0",
      "(or #f #t 1)" => "#t",
      "(or 0 1 2 3 4 5 #t)" => "0",
      "(or #t 0 1 2 3 4 5)" => "#t",
    }}

    it_behaves_like "a primitive"
  end

end

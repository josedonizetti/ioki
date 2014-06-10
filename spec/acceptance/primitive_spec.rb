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

  describe "add1" do
    let(:primitives) {{
      "(add1 0)" => "1",
      "(add1 -1)" => "0",
      "(add1 1)" => "2",
      "(add1 -100)" => "-99",
      "(add1 1000)" => "1001",
      "(add1 536870910)" => "536870911",
      "(add1 -536870912)" => "-536870911",
      "(add1 (add1 0))" => "2",
      "(add1 (add1 (add1 (add1 (add1 (add1 12))))))" => "18"
    }}

    it_behaves_like "a primitive"
  end

  describe "sub1" do
    let(:primitives) {{
      "(sub1 0)" => "-1",
      "(sub1 -1)" => "-2",
      "(sub1 1)" => "0",
      "(sub1 -100)" => "-101",
      "(sub1 1000)" => "999",
      "(sub1 536870910)" => "536870909",
      "(sub1 -536870911)" => "-536870912",
      "(sub1 (sub1 0))" => "-2",
      "(sub1 (sub1 (sub1 (sub1 (sub1 (sub1 12))))))" => "6"
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

  describe "zero?" do
    let(:primitives) {{
      "(zero? 0)" => "#t",
      "(zero? 1)" => "#f",
      "(zero? -1)" => "#f"
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

  describe "lognot" do
    let(:primitives) {{
      "(lognot 0)" => "-1",
      "(lognot -1)" => "0",
      "(lognot 1)" => "-2",
      "(lognot -2)" => "1",
      "(lognot 536870911)" => "-536870912",
      "(lognot -536870912)" => "536870911",
      "(lognot (lognot 237463))" => "237463"
    }}

    it_behaves_like "a primitive"
  end

  describe "+" do
    let(:primitives) {{
      "(+ 1 2 3 4 5)" => "15",
      "(+ 1 -2)" => "-1",
      "(+ -1 2)" => "1",
      "(+ -1 -2)" => "-3",
      "(+ 536870911 -1)" => "536870910",
      "(+ 536870910 1)" => "536870911",
      "(+ -536870912 1)" => "-536870911",
      "(+ -536870911 -1)" => "-536870912",
      "(+ 536870911 -536870912)" => "-1",
      "(+ 1 (+ 2 3))" => "6",
      "(+ 1 (+ 2 -3))" => "0",
      "(+ 1 (+ -2 3))" => "2",
      "(+ 1 (+ -2 -3))" => "-4",
      "(+ -1 (+ 2 3))" => "4",
      "(+ -1 (+ 2 -3))" => "-2",
      "(+ -1 (+ -2 3))" => "0",
      "(+ -1 (+ -2 -3))" => "-6",
      "(+ (+ 1 2) 3)" => "6",
      "(+ (+ 1 2) -3)" => "0",
      "(+ (+ 1 -2) 3)" => "2",
      "(+ (+ 1 -2) -3)" => "-4",
      "(+ (+ -1 2) 3)" => "4",
      "(+ (+ -1 2) -3)" => "-2",
      "(+ (+ -1 -2) 3)" => "0",
      "(+ (+ -1 -2) -3)" => "-6",
      "(+ (+ (+ (+ (+ (+ (+ (+ 1 2) 3) 4) 5) 6) 7) 8) 9)" => "45",
      "(+ 1 (+ 2 (+ 3 (+ 4 (+ 5 (+ 6 (+ 7 (+ 8 9))))))))" => "45"
    }}

    it_behaves_like "a primitive"
  end

  describe "-" do
    let(:primitives) {{
      "(- 1 2 3)" => "-4",
      "(- 1 -2)" => "3",
      "(- -1 2)" => "-3",
      "(- -1 -2)" => "1",
      "(- 536870910 1 2 3 4 5 6 7 8 9 10)" => "536870855",
      "(- 536870911 1)" => "536870910",
      "(- -536870911 1)" => "-536870912",
      "(- -536870912 -1)" => "-536870911",
      "(- 1 536870911)" => "-536870910",
      "(- -1 536870911)" => "-536870912",
      "(- 1 -536870910)" => "536870911",
      "(- -1 -536870912)" => "536870911",
      "(- 536870911 536870911)" => "0",
      #"(- 536870911 -536870912)" => "-1",
      "(- -536870911 -536870912)" => "1",
      "(- 1 (- 2 3))" => "2",
      "(- 1 (- 2 -3))" => "-4",
      "(- 1 (- -2 3))" => "6",
      "(- 1 (- -2 -3))" => "0",
      "(- -1 (- 2 3))" => "0",
      "(- -1 (- 2 -3))" => "-6",
      "(- -1 (- -2 3))" => "4",
      "(- -1 (- -2 -3))" => "-2",
      "(- 0 (- -2 -3))" => "-1",
      "(- (- 1 2) 3)" => "-4",
      "(- (- 1 2) -3)" => "2",
      "(- (- 1 -2) 3)" => "0",
      "(- (- 1 -2) -3)" => "6",
      "(- (- -1 2) 3)" => "-6",
      "(- (- -1 2) -3)" => "0",
      "(- (- -1 -2) 3)" => "-2",
      "(- (- -1 -2) -3)" => "4",
      "(- (- (- (- (- (- (- (- 1 2) 3) 4) 5) 6) 7) 8) 9)" => "-43",
      "(- 1 (- 2 (- 3 (- 4 (- 5 (- 6 (- 7 (- 8 9))))))))" => "5",
    }}

    it_behaves_like "a primitive"
  end

  describe "*" do
    let(:primitives) {{
      "(* 2 3)" => "6",
      "(* 2 3 5 6)" => "180",
      "(* 2 -3)" => "-6",
      "(* -2 3)" => "-6",
      "(* -2 -3)" => "6",
      "(* 536870911 1)" => "536870911",
      "(* 536870911 -1)" => "-536870911",
      "(* -536870912 1)" => "-536870912",
      "(* -536870911 -1)" => "536870911",
      "(* 2 (* 3 4))" => "24",
      "(* (* 2 3) 4)" => "24",
      "(* (* (* (* (* 2 3) 4) 5) 6) 7 (* 8 2))" => "80640",
      "(* 2 (* 3 (* 4 (* 5 (* 6 7)))) 10 10)" => "504000",
    }}

    it_behaves_like "a primitive"
  end


  describe "logand and logor" do
    let(:primitives) {{
      "(logor 3 16)" => "19",
      "(logor 3 5)"  => "7",
      "(logor 3 7)"  => "7",
      "(lognot (logor (lognot 7) 1))" => "6",
      "(lognot (logor 1 (lognot 7)))" => "6",
      "(logand 3 7)" => "3",
      "(logand 3 5)" => "1",
      "(logand 2346 (lognot 2346))" => "0",
      "(logand (lognot 2346) 2346)" => "0",
      "(logand 2376 2376)" => "2376",
    }}

    it_behaves_like "a primitive"
  end

  describe "=" do
    let(:primitives) {{
      "(= 12 13)" => "#f",
      "(= 12 12)" => "#t",
      "(= 16 (+ 13 3))" => "#t",
      "(= 16 (+ 13 13))" => "#f",
      "(= (+ 13 3) 16)" => "#t",
      "(= (+ 13 13) 16)" => "#f",
    }}

    it_behaves_like "a primitive"
  end

  describe "<" do
    let(:primitives) {{
      "(< 12 13)" => "#t",
      "(< 12 12)" => "#f",
      "(< 13 12)" => "#f",
      "(< 16 (+ 13 1))" => "#f",
      "(< 16 (+ 13 3))" => "#f",
      "(< 16 (+ 13 13))" => "#t",
      "(< (+ 13 1) 16)" => "#t",
      "(< (+ 13 3) 16)" => "#f",
      "(< (+ 13 13) 16)" => "#f",
    }}

    it_behaves_like "a primitive"
  end

  describe "<=" do
    let(:primitives) {{
      "(<= 12 13)" => "#t",
      "(<= 12 12)" => "#t",
      "(<= 13 12)" => "#f",
      "(<= 16 (+ 13 1))" => "#f",
      "(<= 16 (+ 13 3))" => "#t",
      "(<= 16 (+ 13 13))" => "#t",
      "(<= (+ 13 1) 16)" => "#t",
      "(<= (+ 13 3) 16)" => "#t",
      "(<= (+ 13 13) 16)" => "#f"
    }}

    it_behaves_like "a primitive"
  end

  describe ">" do
    let(:primitives) {{
      "(> 12 13)" => "#f",
      "(> 12 12)" => "#f",
      "(> 13 12)" => "#t",
      "(> 16 (+ 13 1))" => "#t",
      "(> 16 (+ 13 3))" => "#f",
      "(> 16 (+ 13 13))" => "#f",
      "(> (+ 13 1) 16)" => "#f",
      "(> (+ 13 3) 16)" => "#f",
      "(> (+ 13 13) 16)" => "#t"
    }}

    it_behaves_like "a primitive"
  end

  describe ">=" do
    let(:primitives) {{
      "(>= 12 13)" => "#f",
      "(>= 12 12)" => "#t",
      "(>= 13 12)" => "#t",
      "(>= 16 (+ 13 1))" => "#t",
      "(>= 16 (+ 13 3))" => "#t",
      "(>= 16 (+ 13 13))" => "#f",
      "(>= (+ 13 1) 16)" => "#f",
      "(>= (+ 13 3) 16)" => "#t",
      "(>= (+ 13 13) 16)" => "#t"
    }}

    it_behaves_like "a primitive"
  end

  describe "if" do
    let(:primitives) {{
      "(if (= 12 13) 12 13)" => "13",
      "(if (= 12 12) 13 14)" => "13",
      "(if (< 12 13) 12 13)" => "12",
      "(if (< 12 12) 13 14)" => "14",
      "(if (< 13 12) 13 14)" => "14",
      "(if (<= 12 13) 12 13)" => "12",
      "(if (<= 12 12) 12 13)" => "12",
      "(if (<= 13 12) 13 14)" => "14",
      "(if (> 12 13) 12 13)" => "13",
      "(if (> 12 12) 12 13)" => "13",
      "(if (> 13 12) 13 14)" => "13",
      "(if (>= 12 13) 12 13)" => "13",
      "(if (>= 12 12) 12 13)" => "12",
      "(if (>= 13 12) 13 14)" => "13"
    }}

    it_behaves_like "a primitive"
  end

end

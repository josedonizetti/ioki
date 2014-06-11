require 'spec_helper'

describe Helper do
  it "should convert to array" do
    expressions = {
      "(if #t 12 13)" => ["if", "#t", "12", "13"],
      "(if #f 12 13)" => ["if", "#f", "12", "13"],
      "(if 0 12 13)"  => ["if", "0", "12", "13"],
      "(if () 43 ())" => ["if", "()", "43", "()"],
      "(if #t (if 12 13 4) 17)" => ["if", "#t", "(if 12 13 4)", "17"],
      "(if #f 12 (if #f 13 4))" => ["if", "#f", "12", "(if #f 13 4)"],
      "(if #\\X (if 1 2 3) (if 4 5 6))" => ["if", "#\\X", "(if 1 2 3)", "(if 4 5 6)"],
      "(if (not (boolean? #t)) 15 (boolean? #f))" => ["if", "(not (boolean? #t))", "15", "(boolean? #f)"],
    }
    expressions.each do |sexp, expected|
      got = Helper.convert_sexp_to_array(sexp)
      expect(got).to eq(expected)
    end
  end

  it "should return car" do
    expressions = {
      "(if #t 12 13)" => "if",
      "(fxadd1 43)" => "fxadd1",
      "(boolean? #f)" => "boolean?",
      "(not (boolean? #t))" => "not",
    }
    expressions.each do |sexp, expected|
      got = Helper.car(sexp)
      expect(got).to eq(expected)
    end
  end

  it "should convert let bindins para array" do
    let_body = {
      "([x 5])" => ["x", "5"],
      "([x (+ 1 2)])" => ["x", "(+ 1 2)"],
      "([x (+ 1 2) y 3])" => ["x", "(+ 1 2)", "y", "3"],
      "([x (+ 1 2) y (+ 3 4)])" => ["x", "(+ 1 2)", "y", "(+ 3 4)"]
    }

    let_body.each do |body, expected|
      got = Helper.convert_bindings_to_array(body)
      expect(got).to eq(expected)
    end
  end
end

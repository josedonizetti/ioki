require 'spec_helper'


describe Ioki::Parser do
  it "should convert a sexp to array" do
    expressions = {
      "1" => [1],
      "+" => [:+],
      "\"string\"" => ["\"string\""],
      "#\\c" => ["#\\c"],
      "(add1 0)" => [:add1, 0],
      "(sub1 -1)" => [:sub1, -1],
      "(add1 (add1 0))" => [:add1, [:add1, 0]],
      "(lambda (x) (+ 1 x))" => [:lambda, [:x], [:+, 1, :x]],
        "(define f (lambda (x) (+ 1 x)))" => [:define, :f, [:lambda, [:x], [:+, 1, :x]]],
      "(define q (lambda (a b c)
          (if (= a 1) (+ b c) #f)))" => [:define, :q, [:lambda, [:a, :b, :c], [:if, [:"=", :a, 1], [:+, :b, :c], :"#f"]] ]
    }

    expressions.each do |sexp, expected|
      array = Ioki::Parser.parse(sexp)
      expect(array).to eq(expected)
    end
  end
end

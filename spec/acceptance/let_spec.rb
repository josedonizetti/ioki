require 'spec_helper'

describe Ioki::Emitter do
  shared_examples_for "a form" do
    it "should compile and execute" do
      forms.each do |code, expected|
        got = compile_and_execute_test(code)
        expect(got).to eq(expected)
      end
    end
  end

  describe "let" do
    let(:forms) {{
      "(let ([x 5]) x)" => "5",
      "(let ([x (+ 1 2)]) x)" => "3",
      "(let ([x (+ 1 2)])
         (let ([y (+ 3 4)])
           (+ x y)))" => "10",
      "(let ([x (+ 1 2)])
         (let ([y (+ 3 4)])
           (- y x)))" => "4",
      "(let ([x (+ 1 2)]
              [y (+ 3 4)])
         (- y x))" => "4",
      "(let ([x (let ([y (+ 1 2)]) (* y y))])
         (+ x x))" => "18",
      "(let ([x (+ 1 2)])
         (let ([x (+ 3 4)])
           x))" => "7",
      "(let ([x (+ 1 2)])
         (let ([x (+ x 4)])
           x))" => "7",
      "(let ([t (let ([t (let ([t (let ([t (+ 1 2)]) t)]) t)]) t)]) t)" => "3",
      "(let ([x 12])
         (let ([x (+ x x)])
           (let ([x (+ x x)])
             (let ([x (+ x x)])
               (+ x x)))))" => "192"
     }}

     it_behaves_like "a form"
   end
end

require 'spec_helper'
describe "Procedures" do
  shared_examples_for "a form" do
    it "should compile and execute" do
      procedures.each do |code, expected|
        got = compile_and_execute_test(code)
        expect(got).to eq(expected)
      end
    end
  end

  describe "lambda inline execution" do
      let(:procedures) {{
        "((lambda (x) (+ x 12)) 1)" => "13",
        "((lambda (a b c) (+ a b c)) 1 2 3)" => "6",
        "((lambda (a b c)
            (if (= a 1) (+ b c) #f)) 1 2 3)" => "5",
        "((lambda (a b c)
            (if (= b 2) (+ a c) #f)) 1 2 3)" => "4",
        "((lambda (a b c)
            (if (= c 3) (+ a b) #f)) 1 2 3)" => "3",
      }}

      it_behaves_like "a form"
  end

  describe "letrec" do
      let(:procedures) {{
        "(letrec ([f (lambda (a b) (+ a b))]) (f 10 1))" => "11",
        "(letrec () 12)" => "12",
        "(letrec () (let ([x 5]) (+ x x)))" => "10",
        "(letrec ([f (lambda () 5)]) 7)" => "7",
        "(letrec ([f (lambda () 5)]) (let ([x 12]) x))" => "12",
        "(letrec ([f (lambda () 5)]) (f))" => "5",
        "(letrec ([f (lambda () 5)]) (let ([x (f)]) x))" => "5",
        "(letrec ([f (lambda () 5)]) (+ (f) 6))" => "11",
        "(letrec ([f (lambda () 5)]) (+ 6 (f)))" => "11",
        "(letrec ([f (lambda () 5)]) (- 20 (f)))" => "15",
        "(letrec ([f (lambda () 5)]) (+ (f) (f)))" => "10",
        "(letrec ([f (lambda () (+ 5 7))]
                  [g (lambda () 13)])
          (+ (f) (g)))" => "25",
        "(letrec ([f (lambda (x) (+ x 12))]) (f 13))" => "25",
        "(letrec ([f (lambda (x) (+ x 12))]) (f (f 10)))" => "34",
        "(letrec ([f (lambda (x) (+ x 12))]) (f (f (f 0))))" => "36",
        "(letrec ([f (lambda (x y) (+ x y))]
                  [g (lambda (x) (+ x 12))])
          (f 16 (f (g 0) (+ 1 (g 0)))))" => "41",
        "(letrec ([f (lambda (x) (g x x))]
                  [g (lambda (x y) (+ x y))])
           (f 12))" => "24",
        "(letrec ([f (lambda (x)
                       (if (zero? x)
                           1
                           (* x (f (sub1 x)))))])
            (f 5))" => "120",
        "(letrec ([f (lambda (x acc)
                       (if (zero? x)
                           acc
                           (f (sub1 x) (add1 acc))))])
            (f 5 1))" => "6",
        "(letrec ([f (lambda (x)
                       (if (zero? x)
                           0
                           (+ 1 (f (sub1 x)))))])
            (f 200))" => "200",
        "(letrec ([f (lambda (n)
                   (if (zero? n)
                     0
                     (+ 1 (f (sub1 n)))))])
            (f 500))" => "500"
      }}


    it_behaves_like "a form"
  end
end

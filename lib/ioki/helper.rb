module Helper
  def convert_sexp_to_array(sexp)
    array = []

    counter = 0
    temp = ""
    stack = []

    sexp = sexp[1, sexp.size - 2]
    sexp.each_char do |c|
      case
      when c == ' ' && stack.empty?
        array << temp
        temp = ""
        next
      when c == "("
        stack.push(c)
      when c == ")"
        stack.pop
      end

      temp += c
    end

    array << temp

    array
  end
  module_function :convert_sexp_to_array

  def car(exp)
    exp[1, exp.size - 2].split[0]
  end

  module_function :car
end

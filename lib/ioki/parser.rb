module Ioki
  class Parser
    class << self
      def parse(sexp)
        sexp = sexp.gsub(/\n/, ' ')
        case
        when sexp[0] == "(" && sexp[sexp.size-1] == ")"
          sexp = sexp[1, sexp.size - 2]
          element = ""
          result = []

          counter = 0
          while counter < sexp.size
            c = sexp[counter]
            case
            when c == ' '
              result << convert_element(element) unless element.empty?
              element = ""
              counter += 1
              next
            when c == '('
              element = ""

              size = closing_parenthesis_position(sexp, counter) - counter + 1
              temp = parse(sexp[counter, size].strip)
              result << temp unless temp.empty?

              counter += sexp[counter, size].strip.size

              next
            when c == ')'
              counter += 1
              return result
            end

            element += c
            counter += 1
          end

          result << convert_element(element) unless element.empty?

          result
        else
          [convert_element(sexp)]
        end
      end

      private
      def convert_element(temp)
        case
        when /^[-]?([0-9]*)$/ =~ temp
          temp.to_i
        when temp.start_with?("\"") && temp.end_with?("\"")
          temp
        when temp.start_with?("#\\")
          temp
        else
          temp.to_sym
        end
      end

      def closing_parenthesis_position(sexp, counter)
        stack = []

        while counter < sexp.size
          c = sexp[counter]
          counter += 1
          case
          when c == "("
            stack.push c
          when c == ")"
            stack.pop

            return counter if stack.empty?
          end
        end
      end
    end
  end
end

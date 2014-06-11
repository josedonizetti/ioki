module Ioki
  class Emitter

    WordSize        = 0x4
    FalseValue      = 0x2F
    TrueValue       = 0x6F
    EmptyListValue  = 0x3F
    CharTag         = 0x0F
    CharMask        = 0x3F
    CharShift       = 0x8
    FxShift         = 0x2
    FxMask          = 0x03
    FxTag           = 0x00
    BoolMask        = 0xBF
    BoolBit         = 0x6

    UNARY_PRIMITIVES = {
      "add1" => "emit_add1",
      "sub1" => "emit_sub1",
      "fixnum->char" => "emit_fixnum_to_char",
      "char->fixnum" => "emit_char_to_fixnum",
      "fixnum?" => "emit_fixnum?",
      "zero?" => "emit_zero?",
      "null?" => "emit_null?",
      "boolean?" => "emit_boolean?",
      "char?" => "emit_char?",
      "not" => "emit_not",
      "lognot" => "emit_lognot"
    }

    BINARY_PRIMITIVES = {
      "+" => "emit_add",
      "-" => "emit_sub",
      "*" => "emit_mul",
      "logor" => "emit_logor",
      "logand" => "emit_logand",
      "=" => "emit_equal",
      "<" => "emit_less_than",
      "<=" => "emit_less_than_or_equal",
      ">" => "emit_greater_than",
      ">=" => "emit_greater_than_or_equal",
    }

    FORMS = {
      "if" => "emit_if",
      "or" => "emit_or",
      "and" => "emit_and",
      "let" => "emit_let",
    }

    def initialize(file_name)
      @asm = Asm.new(file_name)
      @counter = 0
    end

    def emit_program(exp)
      asm.section
      asm.globl("_scheme_entry")
      asm.declare_function("_scheme_entry")
      asm.pushl(EBP)
      asm.movl(ESP, EBP)
      asm.call("L_scheme_entry")
      asm.popl(EBP)
      asm.ret

      emit_scheme_entry(exp)

      asm.close
    end

    def emit_scheme_entry(exp)
      asm.declare_function("L_scheme_entry")
      asm.pushl(EBP)
      asm.movl(ESP, EBP)

      env = Env.new(nil)
      @reference_pointer = 0
      emit_expression(exp, env)
      asm.addl(@reference_pointer, ESP) if @reference_pointer != 0

      asm.popl(EBP)
      asm.ret
    end

    def emit_expression(exp, env)
      case
      when env.contain?(exp); emit_var(exp, env)
      when immediate?(exp); asm.movl(immediate_rep(exp, env), EAX)
      when unary_primitive?(exp); emit_unary_primitive(exp, env)
      when binary_primitive?(exp); emit_binary_primitive(exp, env)
      when form?(exp); emit_form(exp, env)
      end
    end

    def emit_unary_primitive(exp, env)
      array = Helper.convert_sexp_to_array(exp)
      emit_expression(array[1], env)
      send(UNARY_PRIMITIVES[array[0]], env)
    end

    def emit_binary_primitive(exp, env)
      args = Helper.convert_sexp_to_array(exp)
      name = args.shift
      send(BINARY_PRIMITIVES[name], args, env)
    end

    def emit_form(exp, env)
      args = Helper.convert_sexp_to_array(exp)
      form = args.shift
      send(FORMS[form], args, env)
    end

    def emit_var(exp, env)
      val = env[exp]
      asm.movl("-#{val}(%ebp)", EAX)
    end

    def immediate_rep(immediate, env)
      case
      when boolean?(immediate)
        return immediate == "#t" ? TrueValue : FalseValue
      when empty_list?(immediate)
        return EmptyListValue
      when char?(immediate)
        immediate = immediate[2,immediate.length-1]
        return (immediate.ord << 8) | 15
      when fixnum?(immediate)
        return immediate.to_i << 2
      end
    end

    # Unary Primitives

    def emit_add1(env)
      asm.addl(immediate_rep(1, env), EAX)
    end

    def emit_sub1(env)
      asm.subl(immediate_rep(1, env), EAX)
    end

    def emit_fixnum_to_char(env)
      asm.shl(CharShift - FxShift, EAX)
      asm.or(CharMask, EAX)
    end

    def emit_char_to_fixnum(env)
      asm.shr(CharShift - FxShift, EAX)
    end

    def emit_fixnum?(env)
      asm.and(FxMask, AL)
      asm.cmp(FxTag, AL)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_zero?(env)
      asm.cmp(0, EAX)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_null?(env)
      asm.cmp(EmptyListValue, EAX)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_boolean?(env)
      asm.and(BoolMask, AL)
      asm.cmp(FalseValue, AL)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_char?(env)
      asm.and(CharMask, AL)
      asm.cmp(CharTag, AL)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_not(env)
      asm.cmp(FalseValue,AL)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_lognot(env)
      asm.shr(FxShift, EAX)
      asm.not(EAX)
      asm.shl(FxShift, EAX)
    end

    # Binary Primitives
    def emit_add(params, env)
      params.reverse.each do |exp|
        emit_expression(exp, env)
        asm.pushl(EAX)
      end

      asm.movl(immediate_rep(0, env), EAX)

      params.each do
        asm.popl(ECX)
        asm.addl(ECX, EAX)
      end
    end

    def emit_sub(params, env)
        params.reverse.each do |exp|
            emit_expression(exp, env)
            asm.pushl(EAX)
        end

        asm.popl(EAX)

        params.shift
        params.each do
          asm.popl(ECX)
          asm.subl(ECX, EAX)
        end
    end

    def emit_mul(params, env)
      params.each do |exp|
        emit_expression(exp, env)
        asm.pushl(EAX)
      end

      asm.popl(EAX)

      # remove fixnum tag
      asm.shr(FxShift, EAX)

      params.pop
      params.each do
        asm.popl(ECX)
        # remove fixnum tag
        asm.shr(FxShift, ECX)
        asm.imul(ECX, EAX)
      end

      # add fixnum tag
      asm.shl(FxShift, EAX)
    end

    def emit_logand(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.and(ECX, EAX)
    end

    def emit_logor(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.or(ECX, EAX)
    end

    def emit_equal(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.cmp(ECX, EAX)
      asm.sete(AL)
      emit_cmp_bool_result
    end

    def emit_less_than(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.cmp(EAX, ECX)
      asm.setl(AL)
      emit_cmp_bool_result
    end

    def emit_less_than_or_equal(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.cmp(EAX, ECX)
      asm.setle(AL)
      emit_cmp_bool_result
    end

    def emit_greater_than(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.cmp(EAX, ECX)
      asm.setg(AL)
      emit_cmp_bool_result
    end

    def emit_greater_than_or_equal(params, env)
      emit_expression(params[0], env)
      asm.pushl(EAX)

      emit_expression(params[1], env)
      asm.popl(ECX)

      asm.cmp(EAX, ECX)
      asm.setge(AL)
      emit_cmp_bool_result
    end

    # Conditionals Forms

    def emit_if(params, env)
      exp1 = params[0]
      exp2 = params[1]
      exp3 = params[2]

      label1 = new_label
      label2 = new_label

      emit_expression(exp1, env)
      asm.cmp(FalseValue, AL)

      asm.je(label1)
      emit_expression(exp2, env)
      asm.jmp(label2)

      asm.label(label1)
      emit_expression(exp3, env)

      asm.label(label2)
    end

    def emit_and(params, env)
      label = new_label

      params.each do |exp|
        emit_expression(exp, env)
        asm.cmp(FalseValue, AL)
        asm.je(label)
      end

      asm.label(label)
    end

    def emit_or(params, env)
      label = new_label

      params.each do |exp|
        emit_expression(exp, env)
        asm.cmp(FalseValue, AL)
        asm.jne(label)
      end

      asm.label(label)
    end

    def emit_let(params, env)
      args = Helper.convert_bindings_to_array(params[0])
      bindings = Hash[*args]

      local_scope = Env.new(env)

      bindings.each do |var, value|
        emit_expression(value, env)
        asm.pushl(EAX)
        local_scope[var] = inc_reference_pointer
      end

      emit_expression(params[1], local_scope)
    end

    private

    def emit_cmp_bool_result
      asm.movzbl(AL, EAX)
      asm.sal(BoolBit, AL)
      asm.or(FalseValue, AL)
    end

    def immediate?(code)
      return true if fixnum?(code) || boolean?(code) || empty_list?(code) || char?(code)
      return false
    end

    def fixnumBits
      value = (WordSize * 8) - FxShift
      value - 1
    end

    def fixnumLower
      -(2 ** fixnumBits)
    end

    def fixnumUpper
      (2 ** fixnumBits) - 1
    end

    def fixnum?(immediate)
      if immediate.kind_of? String
        immediate = immediate.to_i if /^[0-9]/ =~ immediate || /^[-][0-9]/ =~ immediate
      end

      if immediate.kind_of? Fixnum
        return true if immediate >= fixnumLower && immediate <= fixnumUpper
      end

      false
    end

    def boolean?(code)
      code == "#t" || code == "#f"
    end

    def empty_list?(code)
      code == "()"
    end

    def char?(code)
      return code.start_with?("#\\") if code.kind_of?(String)
      false
    end

    def unary_primitive?(exp)
      name = Helper.car(exp)
      UNARY_PRIMITIVES[name] != nil
    end

    def binary_primitive?(exp)
      name = Helper.car(exp)
      BINARY_PRIMITIVES[name] != nil
    end

    def form?(exp)
      name = Helper.car(exp)
      FORMS[name] != nil
    end

    def new_label
      @counter += 1
      "L#{@counter}"
    end

    def inc_reference_pointer
      @reference_pointer += 4
    end

    def asm
      @asm
    end
  end
end

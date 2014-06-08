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

    def initialize(file_name)
      @asm = Asm.new(file_name)
    end

    def immediate?(code)
      return true if fixnum?(code) || boolean?(code) || empty_list?(code) || char?(code)
      return false
    end

    def immediate_rep(immediate)
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

    def emit_program(code)
      asm.section
      asm.globl("_scheme_entry")
      asm.declare_function("_scheme_entry:")
      asm.pushl(EBP)
      asm.movl(ESP, EBP)
      if immediate?(code)
        asm.movl(immediate_rep(code), EAX)
      else
        emit_primitive(code)
      end
      asm.popl(EBP)
      asm.ret
      asm.close
    end

    def emit_primitive(code)
      names = {
        "fxadd1" => "emit_fxadd1",
        "fixnum->char" => "emit_fixnum_to_char",
        "char->fixnum" => "emit_char_to_fixnum",
        "fixnum?" => "emit_fixnum?",
        "fxzero?" => "emit_fxzero?",
        "null?" => "emit_null?",
        "boolean?" => "emit_boolean?",
        "char?" => "emit_char?",
        "not" => "emit_not",
        "fxlognot" => "emit_fxlognot"
      }
      primitive_name, immediate = parse_primitive(code)
      send(names[primitive_name], immediate)
    end

    def emit_fxadd1(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.addl(immediate_rep(1), EAX)
    end

    def emit_fixnum_to_char(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.shl(CharShift - FxShift, EAX)
      asm.or(CharMask, EAX)
    end

    def emit_char_to_fixnum(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.shr(CharShift - FxShift, EAX)
    end

    def emit_fixnum?(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.and(FxMask, AL)
      asm.cmp(FxTag, AL)
      emit_cmp_bool_result
    end

    def emit_fxzero?(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.cmp(0, EAX)
      emit_cmp_bool_result
    end

    def emit_null?(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.cmp(EmptyListValue, EAX)
      emit_cmp_bool_result
    end

    def emit_boolean?(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.and(BoolMask, AL)
      asm.cmp(FalseValue, AL)
      emit_cmp_bool_result
    end

    def emit_char?(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.and(CharMask, AL)
      asm.cmp(CharTag, AL)
      emit_cmp_bool_result
    end

    def emit_not(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.cmp(FalseValue,AL)
      emit_cmp_bool_result
    end

    def emit_fxlognot(immediate)
      asm.movl(immediate_rep(immediate), EAX)
      asm.shr(FxShift, EAX)
      asm.not(EAX)
      asm.shl(FxShift, EAX)
    end

    private

    def emit_cmp_bool_result
      asm.sete(AL)
      asm.movzbl(AL, EAX)
      asm.sal(BoolBit, AL)
      asm.or(FalseValue, AL)
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

    def parse_primitive(code)
      code = code[1, code.length - 2]
      args = code.split(" ")

      return args[0].strip, args[1].strip
    end

    def asm
      @asm
    end
  end
end

module Ioki
  class Emitter

    WordSize      = 0x4
    False         = 0x2F
    True          = 0x6F
    EmptyList     = 0x3F
    CharTag       = 0x0F
    CharMask      = 0x3F
    CharShift     = 0x8
    FxShift       = 0x2
    FxMask        = 0x03
    FxTag         = 0x00
    BoolMask      = 0xBF
    BoolBit       = 0x6

    def initialize(file_name)
      @asm = Asm.new(file_name)
    end

    def immediate?(code)
      return true if fixnum?(code) || boolean?(code) || empty_list?(code) || char?(code)
      return false
    end

    def immediate_rep(code)
      case
      when fixnum?(code); code << 2
      when boolean?(code); code == "#t" ? True : False
      when empty_list?(code); EmptyList
      else; (code.ord << 8) | 15
      end
    end

    def emit_program(code)
      asm.section
      asm.globl("_scheme_entry")
      asm.align("4, 0x90")
      asm.declare_function("_scheme_entry:")
      asm.pushl("%ebp")
      asm.movl("%esp, %ebp")
      if immediate?(code)
        asm.movl("$#{immediate_rep(code)}, %eax")
      else
        emit_primitive(code)
      end
      asm.popl("%ebp")
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
      }
      primitive_name, immediate = parse_primitive(code)
      send(names[primitive_name], immediate)
    end

    def emit_fxadd1(immediate)
      asm.movl("$#{immediate_rep(immediate.to_i)}, %eax")
      asm.addl("$#{immediate_rep(1)}, %eax")
    end

    def emit_fixnum_to_char(immediate)
      asm.movl("$#{immediate_rep(immediate.to_i)}, %eax")
      asm.shl("$#{CharShift - FxShift}, %eax")
      asm.or("$#{CharMask}, %eax")
    end

    def emit_char_to_fixnum(immediate)
      immediate = immediate.delete("#\\")
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.shr("$#{CharShift - FxShift}, %eax")
    end

    def emit_fixnum?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.and("$#{FxMask}, %al")
      asm.cmp("$#{FxTag}, %al")
      emit_cmp_bool_result
    end

    def emit_cmp_bool_result
      asm.sete("%al")
      asm.movzbl("%al, %eax")
      asm.sal("$#{BoolBit}, %al")
      asm.or("$#{False}, %al")
    end

    def emit_fxzero?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.cmp("$0, %eax")
      emit_cmp_bool_result
    end

    def emit_null?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.cmp("$#{EmptyList}, %eax")
      emit_cmp_bool_result
    end

    def emit_boolean?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.and("$#{BoolMask}, %al")
      asm.cmp("$#{False}, %al")
      emit_cmp_bool_result
    end

    def emit_char?(immediate)
      if /([0-9])/ =~ immediate
        immediate = immediate.to_i
      elsif /(#\\)/ =~ immediate
        immediate = immediate.delete("#\\")
      end

      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.and("$#{CharMask}, %al")
      asm.cmp("$#{CharTag}, %al")
      emit_cmp_bool_result
    end

    private

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

    def fixnum?(code)
      if code.kind_of? Fixnum
        return true if code >= fixnumLower && code <= fixnumUpper
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
      code.kind_of? String
      code = code.delete("()")
      code == "" || code.length == 1
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

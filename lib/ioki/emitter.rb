module Ioki
  class Emitter

    False      = 0x2F
    True       = 0x6F
    EmptyList  = 0x3F
    CharShift       = 8
    CharTag         = 0x0F
    CharMask        = 0x3F
    FixnumShift     = 2
    WordSize        = 4
    BoolBit = 6
    FxMask = 0x03
    FxTag = 0x00


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
        "fxzero?" => "emit_fxzero?"
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
      asm.shl("$6, %eax")
      asm.or("$63, %eax")
    end

    def emit_char_to_fixnum(immediate)
      immediate = immediate.delete("#\\")
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.shr("$6, %eax")
    end

    def emit_fixnum?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.and("$3, %al")
      asm.cmp("$0, %al")
      asm.sete("%al")
      asm.movzbl("%al, %eax")
      asm.sal("$6, %al")
      asm.or("$47, %al")
    end

    def emit_fxzero?(immediate)
      immediate = immediate.to_i if /([0-9])/ =~ immediate
      asm.movl("$#{immediate_rep(immediate)}, %eax")
      asm.cmp("$0, %eax")
      asm.sete("%al")
      asm.movzbl("%al, %eax")
      asm.sal("$6, %al")
      asm.or("$47, %al")
    end

    def clean
      FileUtils.rm("test.s")
      FileUtils.rm("test")
    end

    private

    def fixnumBits
      value = (WordSize * 8) - FixnumShift
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
      code = code.delete("()")
      args = code.split(" ")
      return args[0].strip, args[1].strip
    end

    def asm
      @asm
    end
  end
end

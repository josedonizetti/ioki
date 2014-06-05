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


    def initialize(file_name)
      @asm = Asm.new(file_name)
    end

    def immediate(code)
      return true if fixnum?(code) || boolean?(code) || empty_list?(code)
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
      asm.movl("%esp, %ebp\n")
      asm.movl("$#{immediate_rep(code)}, %eax")
      asm.popl("%ebp")
      asm.ret
      asm.close
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
    end

    def asm
      @asm
    end
  end
end

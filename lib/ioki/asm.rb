module Ioki
  class Asm
    def initialize(file_name)
      @file = File.new(file_name, "w")
    end

    def section
      write_tabbed(".section __TEXT,__text,regular,pure_instructions")
    end

    def globl(code)
      write_tabbed(".globl #{code}")
    end

    def align(code)
      write_tabbed(".align #{code}")
    end

    def declare_function(name)
      write(name)
    end

    def movl(code)
      write_tabbed("movl #{code}")
    end

    def addl(code)
      write_tabbed("addl #{code}")
    end

    def pushl(register)
      write_tabbed("pushl #{register}")
    end

    def popl(register)
      write_tabbed("popl #{register}")
    end

    def shl(code)
      write_tabbed("shl #{code}")
    end

    def shr(code)
      write_tabbed("shr #{code}")
    end

    def or(code)
      write_tabbed("or #{code}")
    end

    def and(code)
      write_tabbed("and #{code}")
    end

    def cmp(code)
      write_tabbed("cmp #{code}")
    end

    def sete(code)
      write_tabbed("sete #{code}")
    end

    def movzbl(code)
      write_tabbed("movzbl #{code}")
    end

    def sal(code)
      write_tabbed("sal #{code}")
    end

    def ret
      write_tabbed("ret")
    end

    def close
      @file.close
    end

    private

    def write(code)
      @file.write("#{code}\n")
    end

    def write_tabbed(code)
      @file.write("\t#{code}\n")
    end
  end
end

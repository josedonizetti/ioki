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

    def pushl(register)
      write_tabbed("pushl #{register}")
    end

    def popl(register)
      write_tabbed("popl #{register}")
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

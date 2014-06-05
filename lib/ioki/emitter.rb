module Ioki
  class Emitter
    def initialize(file_name)
      @file = File.new(file_name, "w")
    end

    def immediate(code)
      code << 2
    end

    def emit_program(code)
      write("\t.section __TEXT,__text,regular,pure_instructions\n")
      write("\t.globl _scheme_entry\n")
      write("\t.align 4, 0x90\n")
      write("_scheme_entry:\n")
      write("\tpushl %ebp\n")
      write("\tmovl %esp, %ebp\n")
      write("\tmovl $#{immediate(code)}, %eax\n")
      write("\tpopl %ebp\n")
      write("\tret\n")
      @file.close
    end

    def clean
      FileUtils.rm("test.s")
      FileUtils.rm("test")
    end

    private
    def write(code)
      @file.write(code)
    end
  end
end

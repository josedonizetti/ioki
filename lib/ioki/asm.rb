module Ioki

  EBP = "%ebp"
  ESP = "%esp"
  EAX = "%eax"
  ECX = "%ecx"
  AL = "%al"

  class Asm
    def initialize(file_name)
      @file = File.new(file_name, "w")
    end

    def section
      write_tabbed1(".section __TEXT,__text,regular,pure_instructions")
    end

    def globl(code)
      write_tabbed1(".globl #{code}")
    end

    def align(code)
      write_tabbed1(".align #{code}")
    end

    def declare_function(name)
      write(name)
    end

    def movl(src, dest)
      write_tabbed3("movl", src, dest)
    end

    def addl(src, dest)
      write_tabbed3("addl", src, dest)
    end

    def subl(src, dest)
      write_tabbed3("subl", src, dest)
    end

    def pushl(register)
      write_tabbed2("pushl", register)
    end

    def popl(register)
      write_tabbed2("popl", register)
    end

    def shl(src, dest)
      write_tabbed3("shl", src, dest)
    end

    def shr(src, dest)
      write_tabbed3("shr", src, dest)
    end

    def or(src, dest)
      write_tabbed3("or", src, dest)
    end

    def and(src, dest)
      write_tabbed3("and", src, dest)
    end

    def cmp(src, dest)
      write_tabbed3("cmp", src, dest)
    end

    def sete(register)
      write_tabbed2("sete", register)
    end

    def movzbl(src, dest)
      write_tabbed3("movzbl", src, dest)
    end

    def sal(src, dest)
      write_tabbed3("sal", src, dest)
    end

    def not(register)
      write_tabbed2("not", register)
    end

    def label(label)
      write_tabbed1("#{label}:")
    end

    def je(label)
      write_tabbed2("je", label)
    end

    def jne(label)
      write_tabbed2("jne", label)
    end

    def jmp(label)
      write_tabbed2("jmp", label)
    end

    def ret
      write_tabbed1("ret")
    end

    def close
      @file.close
    end

    private

    def write(code)
      @file.write("#{code}\n")
    end

    def write_tabbed1(ins)
      @file.write("\t#{ins}\n")
    end

    def write_tabbed2(ins, register)
      @file.write("\t#{ins} #{register}\n")
    end

    def write_tabbed3(ins, src, dest)
      src = "$#{src}" if src.kind_of? Fixnum
      @file.write("\t#{ins} #{src}, #{dest}\n")
    end
  end
end

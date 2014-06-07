require 'ioki'

def compile_and_execute_test(program)
  emitter = Ioki::Emitter.new("test.s")
  emitter.emit_program(program)
  got = `sh compile.sh`.chomp
  clean_test_files
  got
end

def clean_test_files
  FileUtils.rm("test.s")
  FileUtils.rm("test")
end

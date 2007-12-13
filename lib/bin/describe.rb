require 'compiler1/bytecode/compiler'
require 'compiler1/bytecode/rubinius'

file = ARGV.shift

fd = File.open(file)
code = fd.read
fd.close

puts "Path: #{file}"
puts "Size: #{code.size} bytes"

compiler = Compiler1::Bytecode::Compiler.new
state = Compiler1::RsLocalState.new

sexp = code.to_sexp
puts "\nSexp:\n  #{sexp.indented_inspect}"

# nx = compiler.fully_normalize(sexp, state)
# puts "\nNormalized Sexp:\n  #{nx.indented_inspect}"
begin
  desc = compiler.compile_as_script(sexp, :__eval_script__, state)
rescue Object => e
  puts "Unable to compile."
  raise e
end
puts "\nAssembly:\n#{desc.assembly}"

puts "Sub methods:"

def show_method(parent)
  parent.literals.each do |lit|
    if Compiler1::Bytecode::MethodDescription === lit
      puts "\n[[ #{parent.name} >> #{lit.name} ]]"
      puts lit.assembly
      show_method(lit)
    end
  end
end

show_method(desc)

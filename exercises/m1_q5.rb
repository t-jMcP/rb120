class MinilangError < StandardError; end
class BadCommandError < MinilangError; end
class EmptyStackError < MinilangError; end

class Minilang
  VALID_COMMANDS = ['PUSH', 'ADD', 'SUB', 'MULT', 'DIV', 'MOD', 'POP', 'PRINT']

  def initialize(program)
    @stack = []
    @register = 0
    @program = program
  end
  
  def eval
    commands = @program.split
    commands.each { |command| execute(command) }
  rescue MinilangError => error
    puts error.message
  end
  
  private
  
    def execute(command)
      if VALID_COMMANDS.include?(command)
        send(command.downcase)
      elsif command.to_i.to_s == command
        @register = command.to_i
      else
        raise BadCommandError, "Invalid command: #{command}"
      end
    end

    def push
      @stack.push(@register)
    end

    def pop
      raise EmptyStackError, "Empty stack" if @stack.empty?
      @register = @stack.pop
    end

    def add
      @register += pop
    end

    def sub
      @register -= pop
    end

    def mult
      @register *= pop
    end

    def div
      @register /= pop
    end

    def mod
      @register = @register % pop
    end

    def print
      puts @register
    end
end

Minilang.new('PRINT').eval
# 0

Minilang.new('5 PUSH 3 MULT PRINT').eval
# 15

Minilang.new('5 PRINT PUSH 3 PRINT ADD PRINT').eval
# 5
# 3
# 8

Minilang.new('5 PUSH 10 PRINT POP PRINT').eval
# 10
# 5

Minilang.new('5 PUSH POP POP PRINT').eval
# Empty stack!

Minilang.new('3 PUSH PUSH 7 DIV MULT PRINT ').eval
# 6

Minilang.new('4 PUSH PUSH 7 MOD MULT PRINT ').eval
# 12

Minilang.new('-3 PUSH 5 XSUB PRINT').eval
# Invalid token: XSUB

Minilang.new('-3 PUSH 5 SUB PRINT').eval
# 8

Minilang.new('6 PUSH').eval
# (nothing printed; no PRINT commands)

module Lexer
  class InvalidCommandName < ParseError; end
  class InvalidOperandType < ParseError; end

  module Matchers
    COMMANDS       = %w(push pop add sub neg not and or eq lt gt label goto if_goto function call return)
    MEMORY_SEGMENT = %w(argument local static constant this that pointer temp)
    SYMBOL         = /[a-zA-Z_\.$:][a-zA-Z0-9_\.$:]*/
    NUMBER         = /[0-9]+/

    COMMAND_MATCHER         = /\A#{Regexp.union(COMMANDS.map{|com| Regexp.new(com)})}\z/
    MEMORY_SEGMENTS_MATCHER = /\A#{Regexp.union(*MEMORY_SEGMENT)}\z/
    OPERANDS_MATCHER        = /\A#{Regexp.union(MEMORY_SEGMENTS_MATCHER, SYMBOL, NUMBER)}\z/
  end

  class TypeMatcher
    def initialize
    end

    def analyze!(tokens)
      return unless tokens
      @tokens = tokens

      validate!
      @tokens.command_type  = command_type
      @tokens.operand_types = operand_types
    end

    private

    def command_type
      @tokens.command.to_sym
    end

    def operand_types
      @tokens.operands.map { |operand|
        case operand
        when Matchers::MEMORY_SEGMENTS_MATCHER
          :"memory_segment/#{operand}"
        when Matchers::SYMBOL
          :symbol
        when Matchers::NUMBER
          :number
        end
      }
    end

    def validate!
      validate_command!
      validate_operand_types!
    end

    def validate_command!
      raise InvalidCommandName unless @tokens.command.match?(Matchers::COMMAND_MATCHER)
    end

    def validate_operand_types!
      raise InvalidOperandType unless @tokens.operands.all? {|x| x.to_s.match?(Matchers::OPERANDS_MATCHER) }
    end
  end
end

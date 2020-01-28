module Lexer
  class TokenCollection
    attr_reader :size, :source_location
    attr_accessor :command_type, :operand_types

    def initialize(tokens, source_location:)
      @tokens = tokens
      @size = tokens.size
      @source_location = source_location
    end

    def command
      @tokens[0]
    end

    def operands
      @tokens.slice(1..2)
    end

    def valid?
      size.between?(1, 3)
    end
  end
end

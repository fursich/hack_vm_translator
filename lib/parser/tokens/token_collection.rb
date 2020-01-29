module Parser
  class TokenCollection
    attr_reader :raw_text, :source_location
    attr_accessor :command_type, :operand_types

    def initialize(tokens, raw_text:, source_location:)
      @tokens = tokens
      @raw_text = raw_text
      @source_location = source_location
    end

    def command
      @tokens[0]
    end

    def operands
      @tokens.slice(1..2)
    end

    def size
      @tokens.size
    end
  end
end

module Parser
  module Matchers
    TOKEN_SIZE     = 1..3
    COMMANDS       = %w(push pop add sub neg not and or eq lt gt label goto if-goto function call return)
    MEMORY_SEGMENT = %w(argument local static constant this that pointer temp)
    SYMBOL         = /[a-zA-Z_\.$:][a-zA-Z0-9_\.$:]*/
    RESERVED_LABEL = /(keyboard|screen|stack|heap)/
    NUMBER         = /[0-9]+/

    COMMAND_MATCHER         = /\A#{Regexp.union(COMMANDS.map{|com| Regexp.new(com)})}\z/
    MEMORY_SEGMENTS_MATCHER = /\A#{Regexp.union(*MEMORY_SEGMENT)}\z/
    OPERANDS_MATCHER        = /\A#{Regexp.union(MEMORY_SEGMENTS_MATCHER, SYMBOL, RESERVED_LABEL, NUMBER)}\z/

    NUMBER_MATCHER          = /\A#{NUMBER}\z/
    RESERVED_LABEL_MATHCER  = /\A#{RESERVED_LABEL}\z/
    SYMBOL_MATCHER          = /\A#{SYMBOL}\z/
  end

  class TypeMatcher
    def initialize(basename:)
      @basename = basename
    end

    def collate!(tokens)
      return unless tokens
      @tokens = tokens

      validate!
      @tokens.command_type  = command_type
      @tokens.operand_types = operand_types
      @tokens
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
        when Matchers::RESERVED_LABEL_MATHCER
          # need to resolve prior to symbol type
          :reserved_label
        when Matchers::SYMBOL_MATCHER
          :symbol
        when Matchers::NUMBER_MATCHER
          :number
        else
          raise ParseError, 'unknown operand type detected' # should have been validated beforehand
        end
      }
    end

    def validate!
      validate_command!
      validate_operand_size!
      validate_operand_types!
    end

    def validate_operand_size!
      return if Matchers::TOKEN_SIZE.include? @tokens.size

      raise Parser::UndefinedCommandPattern, "invalid command forms with <#{@tokens.raw_text}> at line #{@tokens.source_location}"
    end

    def validate_command!
      return if @tokens.command.match?(Matchers::COMMAND_MATCHER)

      raise Parser::InvalidCommandName, "invalid command name detected with <#{@tokens.raw_text}> at line #{@tokens.source_location}"
    end

    def validate_operand_types!
      return if @tokens.operands.all? {|x| x.to_s.match?(Matchers::OPERANDS_MATCHER) }

      raise Parser::InvalidOperandName, "invalid operand type detected with <#{@tokens.raw_text}> at line #{@tokens.source_location}"
    end
  end
end

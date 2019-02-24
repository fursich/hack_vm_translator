require_relative '../utils/configurable.rb'
require_relative './node/base.rb'

module Parser
  module Matchers
    COMMANDS       = %w(push pop add sub neg not and or eq lt gt label goto if_goto function call return)
    MEMORY_SEGMENT = %w(argument local static constant this that pointer temp)
    SYMBOL         = /[a-zA-Z_\.$:][a-zA-Z0-9_\.$:]*/
    NUMBER         = /[0-9]+/

    COMMAND_MATCHER         = /\A#{Regexp.union(COMMANDS.map{|com| Regexp.new(com)})}\z/
    MEMORY_SEGMENTS_MATCHER = /\A#{Regexp.union(*MEMORY_SEGMENT)}\z/
    OPERANDS_MATCHER        = /\A#{Regexp.union(MEMORY_SEGMENTS_MATCHER, SYMBOL, NUMBER)}\z/
  end

  class InvalidCommandName < ParseError; end

  class NodeFactory
    include Configurable
    include Inflector

    def initialize(tokens, source_location:)
      @tokens = tokens
      @source_location = source_location
    end

    def build
      validate!
      command_node_class.new(*operands, source_location: @source_location)
    end

    private

    def command_node_class
      constantize(@tokens.command, base: Parser::Node)
    rescue NameError => e
      raise InvalidCommandName, "invalid command name: \'#{@tokens.command}\' at line #{@source_location}"
    end

    def operands
      operand_types.zip(@tokens.operands).map { |type, value| constantize(type, base: Parser::Node).new(value) }
    rescue NameError => e
      raise InvalidOperandType, "invalid operand type(s): \'#{@tokens.operands.join(' ')}\' at line #{@source_location}"
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

    def matchers
      self.class.matchers
    end

    class << self
      def matchers
        config.matchers
      end

      def matchers=(**matchers)
        configure do |config|
          config.matchers = (config.matchers || {}).merge matchers # TODO config渡しにしたい
        end
      end
    end
  end
end

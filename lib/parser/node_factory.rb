require_relative 'nodes/node.rb'

module Parser
  class NodeFactory
    include Inflector

    def initialize(tokens)
      @tokens = tokens
    end

    def build
      command_node_class.new(*operand_nodes, raw_text: raw_text, source_location: source_location)
    end

    private

    def command_node_class
      constantize(command_type, base: Parser::Node)
    rescue NameError => e
      raise InvalidCommandName, "invalid command name: \'#{command_type}\' at line #{source_location} \n(originally reported as: #{e.class}: #{e.message})"
    end

    def operand_nodes
      operand_types.zip(@tokens.operands).map { |type, value| constantize(type, base: Parser::Node).new(value) }
    rescue NameError => e
      raise InvalidOperandName, "invalid operand type(s): \'#{@tokens.operands.join(' ')}\' at line #{source_location} \n(originally reported as: #{e.class}: #{e.message})"
    end

    def source_location
      @tokens.source_location
    end

    def raw_text
      @tokens.raw_text
    end

    def command_type
      @tokens.command_type
    end

    def operand_types
      @tokens.operand_types
    end
  end
end

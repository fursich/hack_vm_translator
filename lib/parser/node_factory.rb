require_relative 'nodes/node.rb'

module Parser
  class NodeFactory
    include Inflector
    extend Forwardable

    def_delegators :@tokens, *%i(source_location raw_text command_type operands operand_types)

    def initialize(tokens, basename:)
      @tokens = tokens
      @basename = basename
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
      operand_types.zip(operands).map { |type, value| constantize(type, base: Parser::Node).new(value) }
    rescue NameError => e
      raise InvalidOperandName, "invalid operand type(s): \'#{operands.join(' ')}\' at line #{source_location} \n(originally reported as: #{e.class}: #{e.message})"
    end
  end
end

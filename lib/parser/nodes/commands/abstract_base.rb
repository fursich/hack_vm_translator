module Parser
  module Node
    class CommandBase  < Base
      attr_reader :raw_text, :source_location

      def initialize(*operands, raw_text:, source_location:)
        @operands = operands
        @raw_text = raw_text
        @source_location = source_location
        validate!
      end

      def transform
        operand_nodes = @operands.map { |operand| operand.transform }
        expression_node = constantize(last_name, base: Expression::Node)
        expression_node.new(*operand_nodes, raw_text: @raw_text, source_location: @source_location)
      end
    end

    class Command < CommandBase
      def validate!
        raise InvalidOperandSize unless @operands.size == 0
      end
    end

    class CommandWithSingleOperand < CommandBase
      extend Forwardable
      def_delegators :@operands, :first

      def validate!
        raise InvalidOperandSize unless @operands.size == 1
        raise InvalidOperandType unless valid_operand_types?
      end

      def valid_operand_types?
        raise NotImplementedError
      end
    end

    class CommandWithDoubleOperands < CommandBase
      extend Forwardable
      def_delegators :@operands, :first, :last

      def validate!
        raise InvalidOperandSize unless @operands.size == 2
        raise InvalidOperandType unless valid_operand_types?
      end

      def valid_operand_types?
        raise NotImplementedError
      end
    end
  end
end

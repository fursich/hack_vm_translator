module Parser
  module Node
    class CommandBase  < Base
      attr_reader :raw_text, :source_location
      attr_reader :operands

      def initialize(*operands, raw_text:, source_location:)
        @operands        = operands
        @raw_text        = raw_text
        @source_location = source_location
        validate!
      end

      def transform(context)
        operand_nodes = operands.map { |operand| operand.transform(context) }
        expression_node = constantize(last_name, base: Expression::Node)
        expression_node.new(*operand_nodes, raw_text: @raw_text, source_location: @source_location, context: context)
      end

      private

      def validate_oprand_size!(expected:)
        unless operands.size == expected
          raise InvalidOperandSize, "invalid operand size: #{operands.size} (expected: #{expected}) at line #{source_location}"
        end
      end

      def validate_oprand_types!
        unless valid_operand_types?
          raise InvalidOperandType, "invalid operand type: #{operands} at line #{source_location}"
        end
      end
    end

    class Command < CommandBase
      def validate!
        validate_oprand_size!(expected: 0)
      end
    end

    class CommandWithSingleOperand < CommandBase
      extend Forwardable
      def_delegators :@operands, :first

      def validate!
        validate_oprand_size!(expected: 1)
        validate_oprand_types!
      end

      def valid_operand_types?
        raise NotImplementedError
      end
    end

    class CommandWithDoubleOperands < CommandBase
      extend Forwardable
      def_delegators :@operands, :first, :last

      def validate!
        validate_oprand_size!(expected: 2)
        validate_oprand_types!
      end

      def valid_operand_types?
        raise NotImplementedError
      end
    end
  end
end

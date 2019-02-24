module Parser
  class InvalidOperands < ParseError; end
  class InvalidOperandSize < InvalidOperands; end
  class InvalidOperandType < InvalidOperands; end

  module Node
    class Base
      include Inflector

      def transform
        raise NotImplementedError
      end
    end

    class CommandBase  < Base
      def initialize(*operands, source_location:)
        @operands = operands
        @source_location = source_location
        validate!
      end

      def transform
        operand_nodes = @operands.map { |operand| operand.transform }
        expression_node = constantize(last_name, base: Expression::Node)
        expression_node.new(*operand_nodes, source_location: @source_location)
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

    class OperandBase < Base
      def initialize(value)
        @value = value
      end

      def transform
        expression_node = constantize(last_name, base: Expression::Node)
        expression_node.new(@value)
      end
    end

    module MemorySegment
      class SegmentBase < OperandBase

        def transform
          expression_node = constantize(last_name, base: Expression::Node::MemorySegment)
          expression_node.new(@value)
        end

        def type?(type)
          type == :memory_segment
        end

        def segment_name
          self.class.name.split('::').last.downcase
        end
      end

      class Local < SegmentBase
      end

      class Argument < SegmentBase
      end

      class This < SegmentBase
      end

      class That < SegmentBase
      end

      class Pointer < SegmentBase
      end

      class Temp < SegmentBase
      end

      class Constant < SegmentBase
      end

      class Static < SegmentBase
      end
    end

    class Symbol < OperandBase
      def type?(type)
        type == :symbol
      end
    end

    class Number < OperandBase
      def initialize(value)
        super
        @value = @value.to_i
      end

      def type?(type)
        type == :number
      end
    end
  end
end

module Parser
  module Node

    class Push < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:memory_segment) && last.type?(:number)
      end
    end

    class Pop < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:memory_segment) && last.type?(:number)
      end
    end

    class Not < Command
    end

    class And < Command
    end

    class Or < Command
    end


    class Neg < Command
    end

    class Add < Command
    end

    class Sub < Command
    end


    class Eq < Command
    end
    class Lt < Command
    end
    class Gt < Command
    end

    class Label < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class Goto < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class IfGoto < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class Function < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:label) && last.type?(:number)
      end
    end

    class Call < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:label) && last.type?(:number)
      end
    end

    class Return < Command
    end
  end
end

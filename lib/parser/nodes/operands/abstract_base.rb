module Parser
  module Node
    class OperandBase < Base
      def initialize(value)
        @value = value
      end

      def transform
        expression_node = constantize(node_name, base: Expression::Node)
        expression_node.new(@value)
      end

      private

      def node_name
        self.class.name.split('::').last
      end
    end

    module MemorySegment
      class SegmentBase < OperandBase
        def transform
          expression_node = constantize(node_name, base: Expression::Node::MemorySegment)
          expression_node.new(@value)
        end

        def type?(type)
          type == :memory_segment
        end
      end
    end
  end
end

module Parser
  module Node
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
    end
  end
end

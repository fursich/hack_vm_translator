module Parser
  module Node
    class ReservedLabel < OperandBase
      def transform(context)
        expression_node = constantize(:number, base: Expression::Node)
        expression_node.new(transformed_value, context: context)
      end

      def type?(type)
        type == :reserved_label
      end

      private

      def transformed_value
        MEMORY_MAPPING[@value]
      end

      MEMORY_MAPPING = {
        'stack'    => 0x0100,
        'heap'     => 0x0800,
        'screen'   => 'SCREEN',
        'keyboard' => 'KBD',
      }
    end
  end
end

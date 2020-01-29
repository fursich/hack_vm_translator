module Parser
  module Node
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

module Parser
  module Node
    class Symbol < OperandBase
      def type?(type)
        type == :symbol
      end
    end
  end
end

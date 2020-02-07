module Expression
  module Node
    class Push < CommandWithDoubleOperands
      def compile
        <<~"ASSEMBLY".chomp
          #{load_segment}
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end

      def load_segment
        index = @operands.last.value
        @operands.first.load(index)
      end
    end

    class Pop < CommandWithDoubleOperands
      def compile
        <<~"ASSEMBLY".chomp
          @SP
          M = M - 1
          A = M
          D = M
          #{store_segment}
        ASSEMBLY
      end

      def store_segment
        index = @operands.last.value
        @operands.first.store(index)
      end
    end

    class Label    < CommandWithSingleOperand; end
    class Goto     < CommandWithSingleOperand; end
    class IfGoto   < CommandWithSingleOperand; end
    class Function < CommandWithDoubleOperands; end
    class Call     < CommandWithDoubleOperands; end
    class Return   < Command; end
  end
end

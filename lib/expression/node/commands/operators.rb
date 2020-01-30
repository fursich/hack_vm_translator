module Expression
  module Node
    class Not < UnaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = !M
        ASSEMBLY
      end
    end

    class Neg < UnaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = -M
        ASSEMBLY
      end
    end

    class And < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = D & M
        ASSEMBLY
      end
    end

    class Or < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = D | M
        ASSEMBLY
      end
    end


    class Add < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = D + M
        ASSEMBLY
      end
    end

    class Sub < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = D - M
        ASSEMBLY
      end
    end

    class Eq < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          @aaa // **** NEED TO RETHINK UNIQUE LABEL
          D - M; JEQ
          @bbb
          M = 0; JMP
          (aaa)
          M = -1
          (bbb)
        ASSEMBLY
      end
    end

    class Lt < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          @aaa // **** NEED TO RETHINK UNIQUE LABEL
          D - M; JLT
          @bbb
          M = 0; JMP
          (aaa)
          M = -1
          (bbb)
        ASSEMBLY
      end
    end

    class Gt < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          @aaa // **** NEED TO RETHINK UNIQUE LABEL
          D - M; JGT
          @bbb
          M = 0; JMP
          (aaa)
          M = -1
          (bbb)
        ASSEMBLY
      end
    end
  end
end

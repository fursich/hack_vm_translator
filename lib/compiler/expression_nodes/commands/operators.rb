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
          @#{new_symbol}
          D - M; JEQ
          @#{new_symbol}
          M = 0; JMP
          (#{symbol(-1)})
          M = -1
          (#{symbol(0)})
        ASSEMBLY
      end
    end

    class Lt < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          @#{new_symbol}
          D - M; JLT
          @#{new_symbol}
          M = 0; JMP
          (#{symbol(-1)})
          M = -1
          (#{symbol(0)})
        ASSEMBLY
      end
    end

    class Gt < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          @#{new_symbol}
          D - M; JGT
          @#{new_symbol}
          M = 0; JMP
          (#{symbol(-1)})
          M = -1
          (#{symbol(0)})
        ASSEMBLY
      end
    end
  end
end

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
          D = D & M
        ASSEMBLY
      end
    end

    class Or < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          D = D | M
        ASSEMBLY
      end
    end


    class Add < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          D = D + M
        ASSEMBLY
      end
    end

    class Sub < BinaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          D = D - M
        ASSEMBLY
      end
    end

    class Eq < BinaryOperator
      def operation
        if_then = context.new_symbol
        if_else = context.new_symbol

        <<~"ASSEMBLY".chomp
          D = D - M
          @#{if_then}
          D; JEQ
          @#{if_else}
          D = 0; JMP
          (#{if_then})
          D = -1
          (#{if_else})
        ASSEMBLY
      end
    end

    class Lt < BinaryOperator
      def operation
        if_then = context.new_symbol
        if_else = context.new_symbol

        <<~"ASSEMBLY".chomp
          D = D - M
          @#{if_then}
          D; JLT
          @#{if_else}
          D = 0; JMP
          (#{if_then})
          D = -1
          (#{if_else})
        ASSEMBLY
      end
    end

    class Gt < BinaryOperator
      def operation
        if_then = context.new_symbol
        if_else = context.new_symbol

        <<~"ASSEMBLY".chomp
          D = D - M
          @#{if_then}
          D; JGT
          @#{if_else}
          D = 0; JMP
          (#{if_then})
          D = -1
          (#{if_else})
        ASSEMBLY
      end
    end
  end
end

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

    class Label < CommandWithSingleOperand
      def compile
        <<~"ASSEMBLY".chomp
          (#{label_name})
        ASSEMBLY
      end

      def label_name
        @operands.first.value # FIXME: 関数名をコンテクストして持つこと（function.valueとなる）
      end
    end

    class Goto < CommandWithSingleOperand
      def compile
        <<~"ASSEMBLY".chomp
          @#{label_name}
          0;JMP
        ASSEMBLY
      end

      def label_name
        @operands.first.value # FIXME: 関数名をコンテクストして持つこと（function.valueとなる）
      end
    end

    class IfGoto < CommandWithSingleOperand
      def compile
        <<~"ASSEMBLY".chomp
          @SP
          M = M - 1
          A = M
          D = M
          @#{label_name}
          D;JNE
        ASSEMBLY
      end

      def label_name
        @operands.first.value # FIXME: 関数名をコンテクストして持つこと（function.valueとなる）
      end
    end

    class Function < CommandWithDoubleOperands
      def compile
        <<~"ASSEMBLY".chomp
          (#{name})
          @R15
          M = 1

          {#{local_label(:loop_start)}}
          @R15
          D = M
          @#{argc}
          D = D - A
          @#{local_label(:loop_end)}
          D;JGT

          @SP
          A = M
          M = 0
          @SP
          M = M + 1

          @R15
          M = M + 1
          @#{local_label(:loop_start)}
          0;JMP
          {#{local_label(:loop_end)}}
        ASSEMBLY
      end

      def name
        @operands.first.value
      end

      def argc
        @operands.last.value
      end

      def local_label(symbol) # TODO: 衝突しない名前を選ぶ $$.function.label
        "$$.#{name}.#{symbol}"
      end
    end

    class Call < CommandWithDoubleOperands
      def compile
        <<~"ASSEMBLY".chomp
          @#{local_label(:return_address)}
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @LCL
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @ARG
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @THIS
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @THAT
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @#{argc}
          D = A
          @5
          D = D + A
          @SP
          D = A - D
          @ARG
          M = D

          @SP
          D = A
          @LCL
          M = D

          @#{name}
          0;JMP
          (#{local_label(:return_address)})
        ASSEMBLY
      end

      def name
        @operands.first.value
      end

      def argc
        @operands.last.value
      end

      def local_label(symbol) # TODO: 衝突しない名前を選ぶ $$.function.label
        "$$.#{name}.#{symbol}"
      end
    end
    class Return < Command
      def compile
        <<~"ASSEMBLY".chomp
          @LCL
          D = M
          @R15
          M = D

          @5
          A = D - A
          D = M
          @R14
          M = D

          @SP
          M = M - 1
          A = M
          D = M
          @ARG
          M = D

          @ARG
          D = M
          @SP
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @THAT
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @THIS
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @ARG
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @LCL
          M = D

          @R14
          0;JMP
        ASSEMBLY
      end
    end
  end
end
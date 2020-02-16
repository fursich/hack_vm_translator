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

      private

      def load_segment
        index = operands.last.value
        operands.first.load(index)
      end
    end

    class Pop < CommandWithDoubleOperands
      def compile
        prepare_storage_if_necessary(
          <<~"ASSEMBLY".chomp
            @SP
            M = M - 1
            A = M
            D = M
            #{store_segment}
          ASSEMBLY
        )
      end

      private

      def store_segment
        index = operands.last.value
        operands.first.store(index)
      end

      def prepare_storage_if_necessary(str)
        if (preparation = prepare_storage)
          [preparation, str].join("\n")
        else
          str
        end
      end

      def prepare_storage
        index = operands.last.value
        operands.first.prepare_storage(index)
      end
    end

    class Label < CommandWithSingleOperand
      def compile
        <<~"ASSEMBLY".chomp
          (#{label_name})
        ASSEMBLY
      end

      private

      def label_name
        "#{context.function_name}$#{operands.first.value}"
      end
    end

    class Goto < CommandWithSingleOperand
      def compile
        <<~"ASSEMBLY".chomp
          @#{label_name}
          0;JMP
        ASSEMBLY
      end

      private

      def label_name
        "#{context.function_name}$#{operands.first.value}"
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

      private

      def label_name
        "#{context.function_name}$#{operands.first.value}"
      end
    end

    class Function < CommandWithDoubleOperands
      def compile
        context.enter!(function_name: name)

        <<~"ASSEMBLY".chomp
          (#{name})
          @R15
          M = 1

          (#{local_label(:loop_start)})
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
          (#{local_label(:loop_end)})
        ASSEMBLY
      end

      private

      def name
        operands.first.value
      end

      def argc
        operands.last.value
      end

      def local_label(symbol) # TODO: 衝突しない名前を選ぶ $$.function.label
        "$$.#{name}.#{symbol}"
      end
    end

    class Call < CommandWithDoubleOperands
      def compile
        return_address = context.new_symbol

        <<~"ASSEMBLY".chomp
          @#{return_address}
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
          (#{return_address})
        ASSEMBLY
      end

      private

      def name
        operands.first.value
      end

      def argc
        operands.last.value
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

module Expression
  module Node
    class CommandBase < Base
      attr_reader :context
      attr_reader :raw_text, :source_location
      attr_reader :operands

      def initialize(*operands, raw_text:, source_location:, context:)
        @operands        = operands
        @raw_text        = raw_text
        @source_location = source_location
        @context         = context
      end

      def compile(context)
        raise NotImplementedError
      end
    end

    class Command                   < CommandBase; end
    class CommandWithSingleOperand  < CommandBase; end
    class CommandWithDoubleOperands < CommandBase; end

    class UnaryOperator < Command
      def compile
        <<~"ASSEMBLY".chomp
          @SP
          M = M - 1
          A = M
          #{operation}
          @SP
          M = M + 1
        ASSEMBLY
      end
    end

    class BinaryOperator < Command
      def compile
        <<~"ASSEMBLY".chomp
          @SP
          M = M - 1
          A = M
          D = M
          @R15
          M = D
          @SP
          M = M - 1
          A = M
          D = M
          @R15
          #{operation}
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end
    end
  end
end

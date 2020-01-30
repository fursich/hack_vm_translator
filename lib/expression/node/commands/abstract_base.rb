module Expression
  module Node
    class CommandBase < Base
      attr_reader :operands
      def initialize(*operands, source_location:)
        @operands        = operands
        @source_location = source_location
      end

      def compile
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
          A = M - 1
          #{operation}
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
          @SP
          A = M - 1
          #{operation}
        ASSEMBLY
      end
    end
  end
end

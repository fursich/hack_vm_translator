module Expression
  module Node
    class Base
    end

    class CommandBase < Base
      attr_reader :operands
      def initialize(*operands, source_location:)
        @operands = operands
        @source_location = source_location
      end
    end

    class Command < CommandBase
      def compile
        raise NotImplementedError
      end
    end

    class CommandWithSingleOperand < CommandBase
    end

    class CommandWithDoubleOperands < CommandBase
    end

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


    class UnaryOperator < CommandBase
      def compile
        <<~"ASSEMBLY".chomp
          @SP
          A = M - 1
          #{operation}
        ASSEMBLY
      end
    end

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

    class BinaryOperator < CommandBase
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

    class And < UnaryOperator
      def operation
        <<~"ASSEMBLY".chomp
          M = D & M
        ASSEMBLY
      end
    end

    class Or < UnaryOperator
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


    class Label < CommandWithSingleOperand
    end

    class Goto < CommandWithSingleOperand
    end

    class IfGoto < CommandWithSingleOperand
    end

    class Function < CommandWithDoubleOperands
    end

    class Call < CommandWithDoubleOperands
    end

    class Return < Command
    end



    class OperandBase < Base
      def initialize(value)
        @value = value
      end
    end

    module MemorySegment
      class SegmentBase < OperandBase
        def initialize(name)
          @name = name
        end

        private
        # 'screen' => 'SCREEN', 
        # 'kbd' => 'KBD', 
        # 'static' => ?

        REGISTER_ASSIGNMENT = {
          'sp'       => 'SP',
          'local'    => 'LCL',
          'argument' => 'ARG',
          'this'     => 'THIS',
          'that'     => 'THAT',
        }.merge( 13.upto(15).map { |idx| ["r#{idx}", "R#{idx}"] }.to_h )

        REGISTER_INDEX = {
          'pointer'  => 3,
          'temp'     => 5,
        }

        def resolve(memory_segment, index=nil)
          raise NotImplementedError
          REGISTER_ASSIGNMENT[memory_segment]
          reg_idx = REGISTER_INDEX[memory_segment] + index
          "R#{reg_idx}"
        end

        def increment_a(by:)
          (<<~"ASSEMBLY" * by).chomp
            A = A + 1
          ASSEMBLY
        end
      end

      class ImmediateValue < SegmentBase
        def load(index)
          <<~"ASSEMBLY".chomp
            @#{index}
            D = A
          ASSEMBLY
        end
      end

      class DirectReference < SegmentBase
        def load(index) # pointer/temp
          <<~"ASSEMBLY".chomp
            #{access_direct(index)}
            D = M
          ASSEMBLY
        end

        def store(index) # pointer/temp
          <<~"ASSEMBLY".chomp
            #{access_direct(index)}
            M = D
          ASSEMBLY
        end

        private

        def access_direct(index) # pointer/temp
          <<~"ASSEMBLY".chomp
            @#{resolve(index)}
          ASSEMBLY
        end

        def resolve(index)
          reg_idx = REGISTER_INDEX[@name] + index
          "R#{reg_idx}"
        end
      end

      class IndirectReference < SegmentBase
        def load(index) # lcl/arg/this/that
          <<~"ASSEMBLY".chomp
            #{access_indirect(index)}
            D = M
          ASSEMBLY
        end

        def store(index) # lcl/arg/this/that
          <<~"ASSEMBLY".chomp
            #{access_indirect(index)}
            M = D
          ASSEMBLY
        end

        private

        def access_indirect(index) # lcl/arg/this/that
          <<~"ASSEMBLY".chomp
            @#{resolve}
            A = M
            #{increment_a(by: index)}
          ASSEMBLY
        end

        def resolve
          REGISTER_ASSIGNMENT[@name]
        end
      end


      class Constant < ImmediateValue
      end

      class Local < IndirectReference
      end

      class Argument < IndirectReference
      end

      class This < IndirectReference
      end

      class That < IndirectReference
      end

      class Pointer < DirectReference
      end

      class Temp < DirectReference
      end

      class Static < DirectReference
        def resolve(index)
          "#FILENAME#.#{index}"
        end
      end
    end

    class Symbol < OperandBase
    end

    class Number < OperandBase
      attr_reader :value
    end
  end
end

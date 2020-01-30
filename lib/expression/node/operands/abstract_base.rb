module Expression
  module Node
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
    end
  end
end

module Expression
  module Node
    class OperandBase < Base
      attr_reader :value
      attr_reader :context

      def initialize(value, context:)
        @value   = value
        @context = context
      end
    end

    module MemorySegment
      class SegmentBase < OperandBase
        attr_reader :context

        def initialize(name, context:)
          @name = name
          @context = context
        end

        def prepare_storage(_index)
          # override where necessary
        end

        private
        # 'screen' => 'SCREEN', 
        # 'kbd' => 'KBD', 
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
          "@R#{base_index + index.to_i}"
        end
      end

      class StaticReference < DirectReference
        private

        def access_direct(index) # pointer/temp
          "@#{context.basename}.#{index}"
        end
      end

      class IndirectReference < SegmentBase
        def load(index)
          <<~"ASSEMBLY".chomp
            #{access_indirect(index, dest: 'A')}
            D = M
          ASSEMBLY
        end

        def prepare_storage(index)
          <<~"ASSEMBLY".chomp
            #{access_indirect(index, dest: 'D')}
            @R13
            M = D
          ASSEMBLY
        end

        def store(index) # lcl/arg/this/that
          <<~"ASSEMBLY".chomp
            @R13
            M = D
          ASSEMBLY
        end

        private

        def access_indirect(index, dest:) # lcl/arg/this/that
          <<~"ASSEMBLY".chomp
            @#{base_register}
            D = M
            @#{index}
            #{dest} = D + A
          ASSEMBLY
        end
      end
    end
  end
end

module Expression
  module Node
    class OperandBase < Base
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end

    module MemorySegment
      class SegmentBase < OperandBase
        def initialize(name)
          @name = name
        end

        def prepare_storage(_index)
          # override where necessary
        end

        private
        # 'screen' => 'SCREEN', 
        # 'kbd' => 'KBD', 
        # 'static' => ?

        REGISTER_ASSIGNMENT = {
          'sp'       => 'SP',
        }.merge( 13.upto(15).map { |idx| ["r#{idx}", "R#{idx}"] }.to_h )

        def resolve(memory_segment, index=nil) # TODO
          raise NotImplementedError
          REGISTER_ASSIGNMENT[memory_segment]
          reg_idx = REGISTER_INDEX[memory_segment] + index
          "R#{reg_idx}"
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
            @R#{resolve(index)}
          ASSEMBLY
        end

        def resolve(index)
          base_index + index.to_i
        end
      end

      class IndirectReference < SegmentBase
        def load(index)
          <<~"ASSEMBLY".chomp
            #{access_indirect(index)}
            D = M
          ASSEMBLY
        end

        def prepare_storage(index)
          <<~"ASSEMBLY".chomp
            #{access_indirect(index)}
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

        def access_indirect(index) # lcl/arg/this/that
          # FIXME: AD = はload/store両方に対応させるためのワークアラウンド
          <<~"ASSEMBLY".chomp
            @#{resolve}
            D = M
            @#{index}
            AD = D + A
          ASSEMBLY
        end

        def resolve
          base_register
        end
      end
    end
  end
end

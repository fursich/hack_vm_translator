module Expression
  module Node
    module MemorySegment
      class Constant < ImmediateValue
      end

      class Local < IndirectReference
        def base_register
          'LCL'
        end
      end

      class Argument < IndirectReference
        def base_register
          'ARG'
        end
      end

      class This < IndirectReference
        def base_register
          'THIS'
        end
      end

      class That < IndirectReference
        def base_register
          'THAT'
        end
      end

      class Pointer < DirectReference
        def base_index
          3
        end
      end

      class Temp < DirectReference
        def base_index
          5
        end
      end

      class Static   < StaticReference
      end
    end
  end
end

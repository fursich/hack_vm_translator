module Expression
  module Node
    module MemorySegment
      class Constant < ImmediateValue; end
      class Local < IndirectReference; end
      class Argument < IndirectReference; end

      class This < IndirectReference; end
      class That < IndirectReference; end
      class Pointer < DirectReference; end

      class Temp < DirectReference; end
      class Static < DirectReference
        def resolve(index)
          "#FILENAME#.#{index}"
        end
      end
    end
  end
end

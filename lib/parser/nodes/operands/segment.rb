module Parser
  module Node
    module MemorySegment
      class Local    < SegmentBase; end
      class Argument < SegmentBase; end
      class This     < SegmentBase; end
      class That     < SegmentBase; end
      class Pointer  < SegmentBase; end
      class Temp     < SegmentBase; end
      class Static   < SegmentBase; end
      class Constant < SegmentBase
        def type?(type)
          type == :constant
        end
      end
    end
  end
end

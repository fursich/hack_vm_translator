module Parser
  module Node
    module MemorySegment
      class Local    < SegmentBase; end
      class Argument < SegmentBase; end
      class This     < SegmentBase; end
      class That     < SegmentBase; end
      class Pointer  < SegmentBase; end
      class Temp     < SegmentBase; end
      class Constant < SegmentBase; end
      class Static   < SegmentBase; end
    end
  end
end

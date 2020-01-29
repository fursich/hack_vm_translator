module Parser
  class InvalidOperands < ParseError; end
  class InvalidOperandSize < InvalidOperands; end
  class InvalidOperandType < InvalidOperands; end

  module Node
    class Base
      include Inflector

      def transform
        raise NotImplementedError
      end
    end
  end
end

module Parser
  module Node
    class Base
      include Inflector

      def transform
        raise NotImplementedError
      end
    end
  end
end

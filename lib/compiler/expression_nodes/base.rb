module Expression
  module Node
    class Base
      def new_symbol
        LocalSymbol.create
      end

      def symbol(index)
        LocalSymbol.refer(index)
      end

      class LocalSymbol
        @local_symbol_count = 0

        def self.create
          @local_symbol_count += 1
          "__local__#{@local_symbol_count}"
        end

        def self.refer(count)
          "__local__#{@local_symbol_count + count}"
        end
      end
      private_constant :LocalSymbol
    end
  end
end

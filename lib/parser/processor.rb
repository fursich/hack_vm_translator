require_relative 'errors.rb'
require_relative 'tokenizer.rb'
require_relative 'type_matcher.rb'
require_relative 'node_factory.rb'

module Parser
  class Processor
    def initialize(source)
      @source = source
      @counter = LineCounter.new
    end

    def parse!
      @source.map { |source_location, text|
        tokens = Parser::Tokenizer.new(text, source_location: source_location).tokenize
        next if tokens.nil?
        Parser::TypeMatcher.new.collate!(tokens)
        Parser::NodeFactory.new(tokens).build
      }.compact
    end

    private
  
    class LineCounter
      attr_accessor :count

      def initialize
        @count= 0
      end

      def increment!
        @count += 1
      end
    end
  end
end

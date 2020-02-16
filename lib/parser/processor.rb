require_relative 'errors.rb'
require_relative 'tokenizer.rb'
require_relative 'type_matcher.rb'
require_relative 'node_factory.rb'

module Parser
  class Processor
    def initialize(source, basename:)
      @source = source
      @basename = basename
    end

    def parse!
      @source.map { |source_location, text|
        tokens = Parser::Tokenizer.new(text, source_location: source_location).tokenize
        next if tokens.nil?
        Parser::TypeMatcher.new(basename: @basename).collate!(tokens)
        Parser::NodeFactory.new(tokens, basename: @basename).build
      }.compact
    end
  end
end

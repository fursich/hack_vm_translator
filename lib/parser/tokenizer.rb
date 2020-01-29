require_relative 'tokens/token_collection'

module Parser
  class Tokenizer
    def initialize(raw_text, source_location:)
      @raw_text        = raw_text
      @source_location = source_location
    end

    def tokenize
      text = strip_ignorables(@raw_text)
      return if text.empty?
      do_tokenize(text)
    end

    private

    def strip_ignorables(raw_text)
      raw_text.rstrip.lstrip.gsub(/\/\/.*\z/, '')
    end

    def do_tokenize(text)
      tokens = text.split(/\s+/)
      return if tokens.empty?

      TokenCollection.new(tokens, raw_text: @raw_text, source_location: @source_location)
    end
  end
end

require_relative 'token_collection'

module Parser
  class ParseError < StandardError; end
  class UndefinedCommandPattern < ParseError; end

  class Tokenizer

    def initialize(text, source_location:)
      @text   = strip_ignorables(text)
      @source_location = source_location
    end

    def tokenize
      return if @text.empty?
      do_tokenize
    end

    private

    def strip_ignorables(text)
      text.rstrip.lstrip.gsub(/\/\/.*\z/, '')
    end

    def do_tokenize
      tokens = @text.split(/\s+/)
      return if tokens.empty?

      @token_collection = TokenCollection.new(tokens)
      return @token_collection if @token_collection.valid?

      raise UndefinedCommandPattern, "invalid command forms with <#{@text}> at line #{@source_location}"
    end
  end
end

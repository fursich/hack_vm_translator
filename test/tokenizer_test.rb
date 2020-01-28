require_relative './test_helper'

module Lexer
  module TokenizerTestHelper
    def self.tokenizer_with_input(text, source_location:, &block)
      tokenizer = Lexer::Tokenizer.new(text, source_location: source_location)
      block.call tokenizer
    end

    def self.tokens_with_input(text, source_location:, &block)
      tokenizer = Lexer::Tokenizer.new(text, source_location: source_location)
      block.call tokenizer.tokenize
    end
  end

  class TestTokenizer < Minitest::Test
    def test_source_location
      TokenizerTestHelper.tokenizer_with_input(
        "",
        source_location: 123,
      ) do |tokenizer|
        assert_equal 123, tokenizer.instance_eval { @source_location }
      end
    end

    def test_blank_command
      TokenizerTestHelper.tokens_with_input(
        "   ",
        source_location: 123,
      ) do |tokens|
        assert_nil tokens
      end
    end

    def test_comments
      TokenizerTestHelper.tokens_with_input(
        " // comment",
        source_location: 123,
      ) do |tokens|
        assert_nil tokens
      end
    end

    def test_single_command
      TokenizerTestHelper.tokens_with_input(
        "command",
        source_location: 123,
      ) do |tokens|
        assert_instance_of TokenCollection, tokens
        assert_equal 1, tokens.size
      end
    end

    def test_command_with_one_operand
      TokenizerTestHelper.tokens_with_input(
        "command operand",
        source_location: 123,
      ) do |tokens|
        assert_instance_of TokenCollection, tokens
        assert_equal 2, tokens.size
      end
    end

    def test_command_with_two_operands
      TokenizerTestHelper.tokens_with_input(
        "command destination target",
        source_location: 123,
      ) do |tokens|
        assert_instance_of TokenCollection, tokens
        assert_equal 3, tokens.size
      end
    end

    def test_command_with_three_or_more_operands
      TokenizerTestHelper.tokenizer_with_input(
        "command destination target something_added",
        source_location: 123,
      ) do |tokenizer|
        assert_raises(UndefinedCommandPattern) { tokenizer.tokenize }
      end
    end
  end
end

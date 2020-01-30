require 'test_helper'

module Parser
  module TokenizerTestHelper
    def self.tokens_with_input(text, source_location:, &block)
      tokenizer = Parser::Tokenizer.new(text, source_location: source_location)
      block.call tokenizer.tokenize
    end
  end

  class TestTokenizer < Minitest::Test
    def test_source_location
      TokenizerTestHelper.tokens_with_input(
        "foobar",
        source_location: 123,
      ) do |tokens|
        assert_equal 123, tokens.source_location
      end
    end

    def test_raw_text
      raw_text = "push constant 1 // foo bar baz"

      TokenizerTestHelper.tokens_with_input(
        raw_text,
        source_location: 123,
      ) do |tokens|
        assert_equal raw_text, tokens.raw_text
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
      TokenizerTestHelper.tokens_with_input(
        "command destination target something_added",
        source_location: 123,
      ) do |tokens|
        assert_instance_of TokenCollection, tokens
        assert_equal 4, tokens.size
      end
    end
  end
end

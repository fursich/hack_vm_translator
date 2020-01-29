require_relative './test_helper'

module Parser
  module TypeMatcherTestHelper
    def self.tokenize(text, source_location:)
      Parser::Tokenizer.new(text, source_location: source_location).tokenize
    end

    def self.tokens_with_input(text, source_location:, &block)
      tokens = tokenize(text, source_location: source_location)
      Parser::TypeMatcher.new.collate!(tokens)
      block.call tokens
    end
  end

  class TestTypeMatcher < Minitest::Test
    def test_source_location
      TypeMatcherTestHelper.tokens_with_input(
        "pop local 1",
        source_location: 123,
      ) do |tokens|
        assert_equal 123, tokens.source_location
      end
    end

    def test_raw_text
      TypeMatcherTestHelper.tokens_with_input(
        "push local 3",
        source_location: 123,
      ) do |tokens|
        assert_equal "push local 3", tokens.raw_text
      end
    end

    def test_blank_command
      TypeMatcherTestHelper.tokens_with_input(
        "   ",
        source_location: 123,
      ) do |tokens|
        assert_nil tokens
      end
    end

    def test_comments
      TypeMatcherTestHelper.tokens_with_input(
        " // comment",
        source_location: 123,
      ) do |tokens|
        assert_nil tokens
      end
    end

    def test_valid_commands
      valid_commands = %w(push pop add sub neg not and or eq lt gt label goto if_goto function call return)

      valid_commands.each do |command|
        TypeMatcherTestHelper.tokens_with_input(
          command,
          source_location: 123,
        ) do |tokens|
          assert_instance_of TokenCollection, tokens
          assert_equal 1, tokens.size
          assert_equal command.to_sym, tokens.command_type
        end
      end
    end

    def test_invalid_command
      invalid_commands = %w(shift rev mov not! go_to)

      invalid_commands.each do |command|
        tokens = TypeMatcherTestHelper.tokenize(
          command,
          source_location: 123,
        )
        assert_raises(Parser::InvalidCommandName) {
          Parser::TypeMatcher.new.collate!(tokens)
        }
      end
    end

    def test_command_with_one_operand
       TypeMatcherTestHelper.tokens_with_input(
        "label FOO_BAR",
         source_location: 123,
       ) do |tokens|
         assert_instance_of TokenCollection, tokens
         assert_equal 2, tokens.size
         assert_equal :label, tokens.command_type
         assert_equal [:symbol], tokens.operand_types
       end
    end

    def test_command_with_invalid_operand
      invalid_operands = %w(1st_loop, ****, 123a)

      invalid_operands.each do |operand|
        tokens = TypeMatcherTestHelper.tokenize(
          "goto #{operand}",
          source_location: 123,
        )
        assert_raises(Parser::InvalidOperandName) {
          Parser::TypeMatcher.new.collate!(tokens)
        }
      end
    end

    def test_command_with_two_operands
      valid_segments = %w(argument local static constant this that pointer temp)

      valid_segments.each do |segment|
        TypeMatcherTestHelper.tokens_with_input(
         "push #{segment} 3",
          source_location: 123,
        ) do |tokens|
          assert_instance_of TokenCollection, tokens
          assert_equal 3, tokens.size
          assert_equal :push, tokens.command_type
          assert_equal [:"memory_segment/#{segment}", :number], tokens.operand_types
        end
      end
    end

    def test_command_with_three_or_more_operands
      tokens = TypeMatcherTestHelper.tokenize(
        'pop local 3 1',
        source_location: 123,
      )
      assert_raises(Parser::UndefinedCommandPattern) {
        Parser::TypeMatcher.new.collate!(tokens)
      }
    end
  end
end

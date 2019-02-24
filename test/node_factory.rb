require_relative './test_helper'

module Parser
  module NodeFactoryTestHelper
    def self.prepare_builder(text, source_location:)
      tokens  = Parser::Tokenizer.new(text, source_location: source_location).tokenize
      Parser::NodeFactory.new(tokens, source_location: source_location)
    end

    def self.builder_with_input(text, source_location:, &block)
      builder = prepare_builder(text, source_location: source_location)

      block.call builder
    end

    def self.build_with_input(text, source_location:, &block)
      builder = prepare_builder(text, source_location: source_location)

      block.call builder.build
    end
  end

  class TestTokeninzer < Minitest::Test
    def test_source_location
      NodeFactoryTestHelper.builder_with_input(
        '',
        source_location: 123,
      ) do |builder|
        assert_equal 123, builder.instance_eval { @source_location }
      end
    end

    def test_command_push
      NodeFactoryTestHelper.build_with_input(
        'push constant 123',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::Push, object
      end
    end

    def test_command_if_goto
      NodeFactoryTestHelper.build_with_input(
        'if_goto A.Symbol',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::IfGoto, object
      end
    end

    def test_command_invalid_command_name
      NodeFactoryTestHelper.builder_with_input(
        'unless 123',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidCommandName) { builder.build }
      end
    end

    def test_command_invalid_operand_size
      NodeFactoryTestHelper.builder_with_input(
        'add 1 2',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandSize) { builder.build }
      end
    end

    def test_command_illegal_format
      NodeFactoryTestHelper.builder_with_input(
        'goto %123',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end
    end

    def test_command_invalid_argument_type
      NodeFactoryTestHelper.builder_with_input(
        'push 123 local',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end
    end
  end
end

require 'test_helper'

module Parser
  module ProcessorTestHelper
    def self.prepare_processor(source, &block)
      source_with_lineno = source.map_with_index { |text, line_no| [line_no, text] }
      Parser::Processor.new(source_with_lineno)
    end

    def self.processor_with_input(source, &block)
      processor = prepare_processor(source, &block)
      block.call processor
    end

    def self.build_with_input(text, source_location:, &block)
      processor = prepare_processor(source, &block)
      block.call processor.parse!
    end
  end

  class TestProcessor < Minitest::Test
    def test_source_location
      ProcessorTestHelper.build_with_input(
        'push constant 1',
        source_location: 123,
      ) do |command_node|
        assert_equal 123, command_node.source_location
      end
    end

    def test_raw_text
      ProcessorTestHelper.build_with_input(
        'push constant 1',
        source_location: 123,
      ) do |command_node|
        assert_equal 'push constant 1', command_node.raw_text
      end
    end

    def test_command_push
      ProcessorTestHelper.build_with_input(
        'push constant 123',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::Push, object
      end
    end

    def test_command_if_goto
      ProcessorTestHelper.build_with_input(
        'if_goto A.Symbol',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::IfGoto, object
      end
    end

    def test_command_invalid_command_type
      tokens = ProcessorTestHelper.prepare_tokens(
        'pop local 3',
        source_location: 123,
      ).tap { |tokens|
        tokens.command_type = :an_invalid_command_type
      }

      assert_raises(Parser::InvalidCommandName) { Parser::Processor.new(tokens).build }
    end

    def test_command_invalid_operand_type
      tokens = ProcessorTestHelper.prepare_tokens(
        'pop local 3',
        source_location: 123,
      ).tap { |tokens|
        tokens.operand_types[0] = :an_invalid_operand_type
      }

      assert_raises(InvalidOperandName) { Parser::Processor.new(tokens).build }
    end

    def test_command_invalid_argument_type
      ProcessorTestHelper.builder_with_input(
        'push 123 local',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end
    end
  end
end

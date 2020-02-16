require 'test_helper'

module Parser
  module NodeFactoryTestHelper
    def self.prepare_tokens(text, source_location:)
      tokens  = Parser::Tokenizer.new(text, source_location: source_location).tokenize
      Parser::TypeMatcher.new.collate!(tokens)
      tokens
    end

    def self.prepare_builder(text, source_location:)
      tokens = prepare_tokens(text, source_location: source_location)
      Parser::NodeFactory.new(tokens)
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

  class TestNodeFactory < Minitest::Test
    def test_source_location
      NodeFactoryTestHelper.build_with_input(
        'push constant 1',
        source_location: 123,
      ) do |command_node|
        assert_equal 123, command_node.source_location
      end
    end

    def test_raw_text
      NodeFactoryTestHelper.build_with_input(
        'push constant 1',
        source_location: 123,
      ) do |command_node|
        assert_equal 'push constant 1', command_node.raw_text
      end
    end

    def test_command_push
      NodeFactoryTestHelper.build_with_input(
        'push temp 123',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::Push, object
      end
    end

    def test_command_if_goto
      NodeFactoryTestHelper.build_with_input(
        'if-goto A.Symbol',
        source_location: 123,
      ) do |object|
        assert_instance_of Parser::Node::IfGoto, object
      end
    end

    def test_memory_segments_with_numbers
      memory_segments = %w(argument local static constant this that pointer temp)

      memory_segments.each do |memory_segment|
        NodeFactoryTestHelper.build_with_input(
          "pop #{memory_segment} 555",
          source_location: 123,
        ) do |object|
          assert_instance_of Parser::Node::Pop, object
          assert_kind_of Parser::Node::MemorySegment::SegmentBase, object.first
          assert_instance_of Parser::Node::Number, object.last
        end
      end
    end

    def test_constant_with_reserved_labels
      reserved_labels = %w(stack heap screen keyboard)

      reserved_labels.each do |reserved_label|
        NodeFactoryTestHelper.build_with_input(
          "push constant #{reserved_label}",
          source_location: 123,
        ) do |object|
          assert_instance_of Parser::Node::Push, object
          assert_instance_of Parser::Node::MemorySegment::Constant, object.first
          assert_instance_of Parser::Node::ReservedLabel, object.last
        end
      end
    end

    def test_command_invalid_command_type
      tokens = NodeFactoryTestHelper.prepare_tokens(
        'pop local 3',
        source_location: 123,
      ).tap { |tokens|
        tokens.command_type = :an_invalid_command_type
      }

      assert_raises(Parser::InvalidCommandName) { Parser::NodeFactory.new(tokens).build }
    end

    def test_command_invalid_operand_type
      tokens = NodeFactoryTestHelper.prepare_tokens(
        'pop local 3',
        source_location: 123,
      ).tap { |tokens|
        tokens.operand_types[0] = :an_invalid_operand_type
      }

      assert_raises(InvalidOperandName) { Parser::NodeFactory.new(tokens).build }
    end

    def test_command_invalid_argument_size
      NodeFactoryTestHelper.builder_with_input(
        'add 213',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandSize) { builder.build }
      end
    end

    def test_command_invalid_argument_type
      NodeFactoryTestHelper.builder_with_input(
        'push 123 local',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end

      NodeFactoryTestHelper.builder_with_input(
        'push static screen',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end

      NodeFactoryTestHelper.builder_with_input(
        'push constant SCREEN',
        source_location: 123,
      ) do |builder|
        assert_raises(InvalidOperandType) { builder.build }
      end
    end
  end
end

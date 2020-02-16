require 'test_helper'

module Compiler
  module TransformerTestHelper
    def self.prepare_transformer(text, source_location:, basename:)
      source = [[source_location, text]]
      parse_nodes = Parser::Processor.new(source, basename: basename).parse!
      Compiler::Transformer.new(parse_nodes, basename: basename)
    end

    def self.transformer_with_input(text, source_location: 1, basename: 'basename', &block)
      transformer = prepare_transformer(text, source_location: source_location, basename: basename)

      block.call transformer
    end

    def self.transform_with_input(text, source_location: 1, basename: 'basename', &block)
      transformer = prepare_transformer(text, source_location: source_location, basename: basename)

      block.call transformer.transform
    end

    def self.transformed_node_with_input(text, source_location: 1, basename: 'basename', &block)
      transformer = prepare_transformer(text, source_location: source_location, basename: basename)

      nodes = transformer.transform
      block.call nodes.first
    end
  end

  class TestCompilerTransformer < Minitest::Test
    def test_context
      TransformerTestHelper.transformer_with_input(
        'pop argument 2',
      ) do |transformer|
        assert_instance_of Compiler::Transformer::Context, transformer.context
      end
    end

    def test_transformed_command_pop
      TransformerTestHelper.transformed_node_with_input(
        'pop argument 2',
      ) do |node|
        assert_instance_of Expression::Node::Pop, node
      end
    end

    def test_transformed_command_push
      TransformerTestHelper.transformed_node_with_input(
        'push local 2',
      ) do |node|
        assert_instance_of Expression::Node::Push, node
      end
    end

    def test_transformed_command_if_goto
      TransformerTestHelper.transformed_node_with_input(
        'if-goto foo',
      ) do |node|
        assert_instance_of Expression::Node::IfGoto, node
      end
    end

    def test_transformed_command_function
      TransformerTestHelper.transformed_node_with_input(
        'function foo 3',
      ) do |node|
        assert_instance_of Expression::Node::Function, node
      end
    end

    def test_transformed_command_return
      TransformerTestHelper.transformed_node_with_input(
        'return'
      ) do |node|
        assert_instance_of Expression::Node::Return, node
      end
    end

    def test_transformed_command_or
      TransformerTestHelper.transformed_node_with_input(
        'or'
      ) do |node|
        assert_instance_of Expression::Node::Or, node
      end
    end

    def test_transformed_command_add
      TransformerTestHelper.transformed_node_with_input(
        'add'
      ) do |node|
        assert_instance_of Expression::Node::Add, node
      end
    end

    def test_transformed_operands_memory_segments
      memory_segments = %w(argument local static constant this that pointer temp)
      memory_segments.each do |memory_segment|
        TransformerTestHelper.transformed_node_with_input(
          "push #{memory_segment} 3"
        ) do |node|
          first_operand = node.operands.first
          assert_kind_of Expression::Node::MemorySegment::SegmentBase, first_operand
          assert_equal memory_segment, first_operand.name
        end
      end
    end

    def test_transformed_operands_numbers
      numbers = (0..10).to_a

      numbers.each do |number|
        TransformerTestHelper.transformed_node_with_input(
          "pop argument #{number}"
        ) do |node|
          last_operand = node.operands.last
          assert_instance_of Expression::Node::Number, last_operand
          assert_equal number, last_operand.value
        end
      end
    end

    def test_transformed_operands_symbols
      symbols = %w($foo Bar.baz label1 stack0)

      symbols.each do |symbol|
        TransformerTestHelper.transformed_node_with_input(
         "call #{symbol} 2",
        ) do |node|
          first_operand = node.operands.first
          assert_instance_of Expression::Node::Symbol, first_operand
          assert_equal symbol, first_operand.value
        end
      end
    end

    def test_transformed_operands_reserved_labels
      reserved_labels = %w(stack heap screen keyboard)
      memory_mapping = {
        'stack'    => 0x0100,
        'heap'     => 0x0800,
        'screen'   => 'SCREEN',
        'keyboard' => 'KBD',
      }

      reserved_labels.each do |label|
        TransformerTestHelper.transformed_node_with_input(
         "pop constant #{label}",
        ) do |node|
          last_operand = node.operands.last
          assert_instance_of Expression::Node::Number, last_operand
          assert_equal memory_mapping[label], last_operand.value
        end
      end
    end
  end
end

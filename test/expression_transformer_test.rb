require_relative './test_helper'

module Expression
  module ExpressionTransformerTestHelper
    def self.prepare_node(text, source_location:)
      tokens  = Parser::Tokenizer.new(text, source_location: source_location).tokenize
      parse_node = Parser::NodeFactory.new(tokens, source_location: source_location).build
    end

    def self.node_with_input(text, source_location:, &block)
      node = prepare_node(text, source_location: source_location)

      block.call node
    end

    def self.expression_with_input(text, source_location:, &block)
      node = prepare_node(text, source_location: source_location)

      block.call node.transform
    end
  end

  class TestExpressionTransformer < Minitest::Test
    def test_source_location
      ExpressionTransformerTestHelper.node_with_input(
        'pop argument 2',
        source_location: 123,
      ) do |node|
        assert_equal 123, node.instance_eval { @source_location }
      end
    end

    def test_command_push
      ExpressionTransformerTestHelper.expression_with_input(
        'push constant 123',
        source_location: 123,
      ) do |expression|
        assert_instance_of Expression::Node::Push, expression
      end
    end

    def test_command_pop
      ExpressionTransformerTestHelper.expression_with_input(
        'pop this 3',
        source_location: 123,
      ) do |expression|
        assert_instance_of Expression::Node::Pop, expression
      end
    end

    def test_command_if_goto
      ExpressionTransformerTestHelper.expression_with_input(
        'if_goto A.Symbol',
        source_location: 123,
      ) do |expression|
        assert_instance_of Expression::Node::IfGoto, expression
      end
    end
  end
end

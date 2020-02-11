require 'test_helper'

module Compilar
  module ExpressionNodeTestHelper
    def self.prepare_node(text, source_location:)
      source = [[source_location, text]]
      parse_node = Parser::Processor.new(source).parse!
      parse_node.first.transform
    end

    def self.node_with_input(text, source_location:, &block)
      node = prepare_node(text, source_location: source_location)

      block.call node
    end
  end

  class TestExpressionNode < Minitest::Test
    def test_source_location
      ExpressionNodeTestHelper.node_with_input(
        'pop argument 2',
        source_location: 123,
      ) do |node|
        assert_equal 123, node.instance_eval { @source_location }
      end
    end
  end
end

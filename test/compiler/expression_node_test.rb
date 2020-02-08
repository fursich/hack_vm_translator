require 'test_helper'

module Expression
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
    def test_command_push_constant
      ExpressionNodeTestHelper.node_with_input(
        'push constant 2',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile
          @2
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end
    end

    def test_command_push_pointer
      ExpressionNodeTestHelper.node_with_input(
        'push pointer 1',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile
          @R4
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end
    end

    def test_command_push_this
      ExpressionNodeTestHelper.node_with_input(
        'push this 5',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile
          @THIS
          D = M
          @5
          AD = D + A
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end
    end

    def test_command_pop_argument
      ExpressionNodeTestHelper.node_with_input(
        'pop argument 2',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile
          @ARG
          D = M
          @3
          D = D + A
          @R13
          M = D

          @SP
          M = M - 1
          A = M
          D = M
          @R13
          M = D
        ASSEMBLY
      end
    end

    def test_command_pop_temp
      ExpressionNodeTestHelper.node_with_input(
        'pop temp 3',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile

          @SP
          M = M - 1
          A = M
          D = M
          @R8
          M = D
        ASSEMBLY
      end
    end

    def test_command_add
      ExpressionNodeTestHelper.node_with_input(
        'add',
        source_location: 3,
      ) do |node|
        assert_equal <<~"ASSEMBLY".chomp, node.compile
          @SP
          M = M - 1
          A = M
          D = M
          @SP
          A = M - 1
          M = D + M
        ASSEMBLY
      end
    end
  end
end

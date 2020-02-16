require 'test_helper'

module Parser
  module ProcessorTestHelper
    def self.prepare_processor(*text, basename: 'basename', &block)
      text_with_lineno = text.map.with_index(1) { |text, line_no| [line_no, text] }
      Parser::Processor.new(text_with_lineno, basename: basename)
    end

    def self.processor_with_input(*text, basename: 'basename', &block)
      processor = prepare_processor(*text, basename: basename, &block)
      block.call processor
    end

    def self.process(*text, basename: 'basename', &block)
      processor = prepare_processor(*text, basename: basename, &block)
      block.call processor.parse!
    end
  end

  class TestProcessor < Minitest::Test
    def test_source_location
      ProcessorTestHelper.process(
        'push constant 1',
        'if-goto A.Symbol',
      ) do |nodes|
        assert_equal 1, nodes[0].source_location
        assert_equal 2, nodes[1].source_location
      end
    end

    def test_raw_text
      ProcessorTestHelper.process(
        'pop local 3',
        'push constant 10',
      ) do |nodes|
        assert_equal 'pop local 3', nodes[0].raw_text
        assert_equal 'push constant 10', nodes[1].raw_text
      end
    end

    def test_node_instances
      ProcessorTestHelper.process(
        'push constant 123',
        'if-goto A.Symbol',
      ) do |nodes|
        assert_instance_of Parser::Node::Push, nodes[0]
        assert_instance_of Parser::Node::IfGoto, nodes[1]
      end
    end

    def test_node_numbers
      ProcessorTestHelper.process(
        'push this 10',
        'if-goto A.Symbol',
        'pop local 3',
        'push local 3',
        'return',
      ) do |nodes|
        assert_equal 5, nodes.size
      end
    end
  end
end

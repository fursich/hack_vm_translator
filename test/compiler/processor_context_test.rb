require 'test_helper'

module Compiler
  module ProcessorContextTestHelper
    def self.prepare_processor(text, source_location:, basename:)
      source = [[source_location, text]]
      parsed_source = Parser::Processor.new(source, basename: basename).parse!
      Compiler::Processor.new(parsed_source, basename: basename)
    end

    def self.context_after_initialize(text, source_location: 1, basename: 'basename', &block)
      processor = prepare_processor(text, source_location: source_location, basename: basename)

      context = processor.instance_variable_get(:@transformer).context

      block.call context
    end

    def self.context_before_compile(text, source_location: 1, basename: 'basename', &block)
      processor = prepare_processor(text, source_location: source_location, basename: basename).tap(&:transform)

      context = processor.instance_variable_get(:@transformer).context

      block.call context
    end

    def self.context_after_compile(text, source_location: 1, basename: 'basename', &block)
      processor = prepare_processor(text, source_location: source_location, basename: basename).tap(&:compile)

      context = processor.instance_variable_get(:@transformer).context

      block.call context
    end
  end

  class TestCompilerProcessorContext < Minitest::Test
    def test_context
      Compiler::ProcessorContextTestHelper.context_after_initialize(
        'push constant 2',
        basename: 'source_file',
      ) do |context|
        assert_instance_of Compiler::Transformer::Context, context
      end
    end

    def test_basename_are_properly_set_before_and_after_compile
      Compiler::ProcessorContextTestHelper.context_before_compile(
        'push constant 2',
        basename: 'source_file',
      ) do |context|
        assert_equal 'source_file', context.basename
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'push constant 2',
        basename: 'source_file',
      ) do |context|
        assert_equal 'source_file', context.basename
      end
    end

    def test_function_name_with_non_function_commands
      Compiler::ProcessorContextTestHelper.context_after_compile(
        'pop argument 2',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'push local 12',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'label foo',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'goto foo',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'return',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'call foo 3',
      ) do |context|
        assert_nil context.function_name
      end
    end

    def test_function_name_are_properly_set_with_function
      Compiler::ProcessorContextTestHelper.context_before_compile(
        'function foo 3',
        basename: 'source_file',
      ) do |context|
        assert_nil context.function_name
      end

      Compiler::ProcessorContextTestHelper.context_after_compile(
        'function foo 3',
        basename: 'source_file',
      ) do |context|
        assert_equal 'foo', context.function_name
      end
    end

    def test_new_symbol_are_generated_as_the_counter_increases
      Compiler::ProcessorContextTestHelper.context_before_compile(
        'function foo 3',
        basename: 'source_file',
      ) do |context|
        assert_equal 0, context.counter
        assert_equal '$.local.source_file.1', context.new_symbol
        assert_equal '$.local.source_file.2', context.new_symbol
        assert_equal 2, context.counter
      end
    end
  end
end

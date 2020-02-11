require 'test_helper'

module Compiler
  module ProcessorTestHelper
    def self.prepare_compiler(text, source_location:)
      source = [[source_location, text]]
      parsed_source = Parser::Processor.new(source).parse!
      Compiler::Processor.new(parsed_source)
    end

    def self.compile_with_input(text, source_location:, &block)
      compiler = prepare_compiler(text, source_location: source_location)

      block.call compiler.compile.first
    end
  end

  class TestCompilerProcessor < Minitest::Test
    def test_command_push_constant
      Compiler::ProcessorTestHelper.compile_with_input(
        'push constant 2',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
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
      Compiler::ProcessorTestHelper.compile_with_input(
        'push pointer 1',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
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
      Compiler::ProcessorTestHelper.compile_with_input(
        'push this 5',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
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
      Compiler::ProcessorTestHelper.compile_with_input(
        'pop argument 2',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
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
      Compiler::ProcessorTestHelper.compile_with_input(
        'pop temp 3',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output

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
      Compiler::ProcessorTestHelper.compile_with_input(
        'add',
        source_location: 3,
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
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

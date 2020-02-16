require 'test_helper'

module Compiler
  module ProcessorTestHelper
    def self.prepare_compiler(text, source_location:, basename:)
      source = [[source_location, text]]
      parsed_source = Parser::Processor.new(source).parse!
      Compiler::Processor.new(parsed_source, basename: basename)
    end

    def self.compile_with_input(text, source_location: 1, basename: 'basename', &block)
      compiler = prepare_compiler(text, source_location: source_location, basename: basename)

      block.call compiler.compile.first
    end
  end

  class TestCompilerProcessor < Minitest::Test
    def test_command_push_constant
      Compiler::ProcessorTestHelper.compile_with_input(
        'push constant stack',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @256
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end

      Compiler::ProcessorTestHelper.compile_with_input(
        'push constant heap',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @2048
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end

      Compiler::ProcessorTestHelper.compile_with_input(
        'push constant screen',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @SCREEN
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
        ASSEMBLY
      end


      Compiler::ProcessorTestHelper.compile_with_input(
        'push constant keyboard',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @KBD
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

    def test_command_push_static
      Compiler::ProcessorTestHelper.compile_with_input(
        'push static 4',
        basename: 'basename'
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @basename.4
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
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @THIS
          D = M
          @5
          A = D + A
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
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @ARG
          D = M
          @2
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

    def test_command_pop_static
      Compiler::ProcessorTestHelper.compile_with_input(
        'pop static 9',
        basename: 'basename',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output

          @SP
          M = M - 1
          A = M
          D = M
          @basename.9
          M = D
        ASSEMBLY
      end
    end

    def test_command_add
      Compiler::ProcessorTestHelper.compile_with_input(
        'add',
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

require 'test_helper'

module Compiler
  module ProcessorTestHelper
    def self.prepare_processor(text, source_location:, basename:)
      source = [[source_location, text]]
      parsed_source = Parser::Processor.new(source, basename: basename).parse!
      Compiler::Processor.new(parsed_source, basename: basename)
    end

    def self.compile_with_input(text, source_location: 1, basename: 'basename', &block)
      compiler = prepare_processor(text, source_location: source_location, basename: basename)

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

    def test_command_function
      Compiler::ProcessorTestHelper.compile_with_input(
        'function foo 2',
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          (foo)
          @R15
          M = 1

          ($$.foo.loop_start)
          @R15
          D = M
          @2
          D = D - A
          @$$.foo.loop_end
          D;JGT

          @SP
          A = M
          M = 0
          @SP
          M = M + 1

          @R15
          M = M + 1
          @$$.foo.loop_start
          0;JMP
          ($$.foo.loop_end)
        ASSEMBLY
      end
    end

    def test_command_call
      Compiler::ProcessorTestHelper.compile_with_input(
        'call foobar 2',
        basename: 'basename'
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @$.local.basename.1
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @LCL
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @ARG
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @THIS
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @THAT
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1

          @2
          D = A
          @5
          D = D + A
          @SP
          D = A - D
          @ARG
          M = D

          @SP
          D = A
          @LCL
          M = D

          @foobar
          0;JMP
          ($.local.basename.1)
        ASSEMBLY
      end
    end

    def test_command_return
      Compiler::ProcessorTestHelper.compile_with_input(
        'return'
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @LCL
          D = M
          @R15
          M = D

          @5
          A = D - A
          D = M
          @R14
          M = D

          @SP
          M = M - 1
          A = M
          D = M
          @ARG
          M = D

          @ARG
          D = M
          @SP
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @THAT
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @THIS
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @ARG
          M = D

          @R15
          M = M - 1
          A = M
          D = M
          @LCL
          M = D

          @R14
          0;JMP
        ASSEMBLY
      end
    end

    def test_label
      processor = Compiler::ProcessorTestHelper.prepare_processor(
        'label foo',
        source_location: 123,
        basename: 'basename'
      )

      context = processor.instance_variable_get(:@transformer).context
      context.instance_variable_set(:@function_name, 'a_function')

      assert_equal <<~ASSEMBLY.chomp, processor.compile.first
        (a_function$foo)
      ASSEMBLY
    end

    def test_goto
      processor = Compiler::ProcessorTestHelper.prepare_processor(
        'goto foo',
        source_location: 123,
        basename: 'basename'
      )

      context = processor.instance_variable_get(:@transformer).context
      context.instance_variable_set(:@function_name, 'a_function')

      assert_equal <<~ASSEMBLY.chomp, processor.compile.first
        @a_function$foo
        0;JMP
      ASSEMBLY
    end

    def test_if_goto
      processor = Compiler::ProcessorTestHelper.prepare_processor(
        'if-goto foo',
        source_location: 123,
        basename: 'basename'
      )

      context = processor.instance_variable_get(:@transformer).context
      context.instance_variable_set(:@function_name, 'a_function')

      assert_equal <<~ASSEMBLY.chomp, processor.compile.first
        @SP
        M = M - 1
        A = M
        D = M
        @a_function$foo
        D;JNE
      ASSEMBLY
    end
  end
end

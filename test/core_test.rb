require 'test_helper'

module VMTranslator
  module CoreHelper
    def self.prepare_core(text, source_location:, basename:, debug: false)
      source = text.split(/\r?\n/).map.with_index(source_location){ |line, index| [index, line] }
      VMTranslator::Core.new(source, basename: basename, debug: debug)
    end

    def self.core_with_input(text, source_location: 1, basename: 'basename', &block)
      core = prepare_core(text, source_location: source_location, basename: basename)

      block.call core
    end

    def self.process_with_input(text, source_location: 1, basename: 'basename', &block)
      core = prepare_core(text, source_location: source_location, basename: basename)

      block.call core.process
    end
  end

  class TestVMTranlatorCore < Minitest::Test
    def test_source
      core = VMTranslator::Core.new(
        [[333, 'push argument 1']],
        basename: 'basename',
      )
      assert_equal [[333, 'push argument 1']], core.source
    end

    def test_basename
      core = VMTranslator::Core.new(
        [[333, 'push argument 1']],
        basename: 'basename',
      )
      assert_equal 'basename', core.basename
    end

    def test_assembly_before_process
      core = VMTranslator::Core.new(
        [[333, 'push argument 1']],
        basename: 'basename',
      )
      assert_nil core.assembly
    end

    def test_command_push_constant
      source = <<~SOURCE
        push constant stack
        pop  constant screen
        push constant keyboard
        push constant heap
      SOURCE

      VMTranslator::CoreHelper.process_with_input(
        source
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @256
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
          @SP
          M = M - 1
          A = M
          D = M
          @SCREEN
          M = D
          @KBD
          D = A
          @SP
          A = M
          M = D
          @SP
          M = M + 1
          @2048
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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
      VMTranslator::CoreHelper.process_with_input(
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

    def test_multiple_commands_add_and_pop
      source = <<~SOURCE
        push static 1
        push argument 2
        add
        pop temp 4
      SOURCE

      VMTranslator::CoreHelper.process_with_input(
        source,
        basename: 'source_file'
      ) do |output|
        assert_equal <<~"ASSEMBLY".chomp, output
          @source_file.1
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1
          @ARG
          D = M
          @2
          A = D + A
          D = M
          @SP
          A = M
          M = D
          @SP
          M = M + 1
          @SP
          M = M - 1
          A = M
          D = M
          @SP
          A = M - 1
          M = D + M
          @SP
          M = M - 1
          A = M
          D = M
          @R9
          M = D
        ASSEMBLY
      end
    end
  end
end

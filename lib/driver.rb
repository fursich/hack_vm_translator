# usage
# load 'lib/driver.rb'
# translator = VMTranslator::Driver.new('add/Add.vm')
# translator.run

require 'forwardable'

require_relative 'utils/fileio'
require_relative 'utils/inflector'
require_relative 'core'

module VMTranslator
  class Driver
    attr_reader :source, :commands, :symbols

    def initialize(filename)
      @filename = Pathname.new(filename)
      raise FileError, 'illegal file type' if @filename.extname != '.vm'
      @output_filename = @filename.sub_ext('.asm')

      @source = read_file
    end

    def run
      @assembly = compile.join("\n")
      print
      write_file
    end

    def read_file
      FileIO.new(@filename).read
    end

    def write_file
      FileIO.new(@output_filename).write(@assembly)
    end

    def compile
      parsed_source = Parser::Processor.new(@source).parse!
      Compiler::Processor.new(parsed_source, basename: @filename.basename).compile
    end

    def print
      basename = @filename.basename('.*').to_s
      puts "compiled: #{basename}"
      puts @assembly
      puts
    end
  end
end

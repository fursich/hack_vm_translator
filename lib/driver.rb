# usage
# load 'lib/driver.rb'
# translator = VMTranslator::Driver.new('add/Add.vm')
# translator.run

require 'forwardable'

require_relative 'utils/fileio'
require_relative 'utils/inflector'
require_relative 'parser/tokenizer'
require_relative 'parser/node_factory'
require_relative 'expression/node/base'

module VMTranslator
  class Driver
    attr_reader :source, :commands, :symbols

    def initialize(filename)
      @filename = Pathname.new(filename)
      raise FileError, 'illegal file type' if @filename.extname != '.vm'
      @output_filename = @filename.sub_ext('.asm')

      @source = read_file
      reset_line_counter!
    end

    def run
      @assembly = compile.join("\n")
      link!
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
      @source.map do |source_location, text|
        tokens = Parser::Tokenizer.new(text, source_location: source_location).tokenize
        next if tokens.nil?

        # increment_line_counter! # TODO: set line counter
        parse_node = Parser::NodeFactory.new(tokens, source_location: source_location).build
        p parse_node
        parse_node.transform.compile
      end
    end

    def link!
      basename = @filename.basename('.*').to_s
      puts basename
      @assembly.gsub!('#FILENAME#', basename)
    end

    def print
      puts @assembly
    end

    private

    def line_counter
      @line_counter ||= 0
    end
    
    def increment_line_counter!
      @line_counter = line_counter + 1
    end

    def reset_line_counter!
      @line_counter = 0
    end
  end
end

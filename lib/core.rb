# usage
# load 'lib/driver.rb'
# translator = VMTranslator::Driver.new('add/Add.vm')
# translator.run

require_relative 'parser/processor'
require_relative 'compiler/processor'

module VMTranslator
  class Core
    attr_reader :source, :assembly, :basename

    def initialize(source, basename:, debug: false)
      @source = source
      @basename = basename
      @debug = debug
    end

    def process
      @assembly = compile.join("\n")
      print if @debug
      assembly
    end

    private

    def compile
      parsed_source = Parser::Processor.new(@source).parse!
      Compiler::Processor.new(parsed_source, basename: @basename).compile
    end

    def print
      puts "compiled: #{@basename}"
      puts @assembly
      puts
    end
  end
end

require_relative 'expression_nodes/node'

module Compiler
  class Processor
    def initialize(source, basename:)
      @source = source
      @context = Context.new(basename)
    end

    def transform
      @source.map do |node|
        node.transform(@context)
      end
    end

    def compile
      transform.map do |node|
        node.compile
      end
    end

    class Context
      attr_reader :basename, :function_name

      def initialize(basename)
        @basename = basename
      end

      def enter!(function_name:)
        @function_name = function_name
      end
    end
  end
end


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
      attr_reader :basename, :function_name, :counter

      def initialize(basename)
        @basename = basename
        @counter = 0
      end

      def enter!(function_name:)
        @function_name = function_name
      end

      def new_symbol
        increment_counter!

        "$.local.#{basename}.#{counter}"
      end

      private

      def increment_counter!
        @counter += 1
      end
    end
  end
end


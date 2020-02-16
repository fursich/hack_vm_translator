require_relative 'expression_nodes/node'

module Compiler
  class Transformer
    attr_reader :context

    def initialize(nodes, basename:)
      @context = Context.new(basename)
      @nodes = nodes
    end

    def transform
      @nodes.map do |node|
        node.transform(@context)
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


require_relative 'expression_nodes/node'

module Compiler
  class Processor
    def initialize(source)
      @source = source
    end

    def transform
      @source.map do |node|
        node.transform
      end
    end

    def compile
      transform.map do |node|
        node.compile
      end
    end
  end
end


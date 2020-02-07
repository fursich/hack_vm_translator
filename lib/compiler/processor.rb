require_relative 'expression_nodes/node'

module Compiler
  class Processor
    def initialize(source)
      @source = source
    end

    def transform_all
      @source.map do |node|
        node.transform
      end
    end
  end
end


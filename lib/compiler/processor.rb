require_relative 'expression_nodes/node'
require_relative 'transformer'

module Compiler
  class Processor
    extend Forwardable
    def_delegators :@transformer, :transform

    def initialize(source, basename:)
      @transformer = Transformer.new(source, basename: basename)
    end

    def compile
      transform.map do |node|
        node.compile
      end
    end
  end
end


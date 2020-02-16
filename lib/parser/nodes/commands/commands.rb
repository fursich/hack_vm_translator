module Parser
  module Node
    class Not    < Command; end
    class And    < Command; end
    class Or     < Command; end

    class Neg    < Command; end
    class Add    < Command; end
    class Sub    < Command; end

    class Eq     < Command; end
    class Lt     < Command; end
    class Gt     < Command; end

    class Return < Command; end

    class Label    < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class Goto     < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class IfGoto   < CommandWithSingleOperand
      def valid_operand_types?
        first.type?(:symbol)
      end
    end

    class Push     < CommandWithDoubleOperands
      def valid_operand_types?
        if first.type?(:constant)
          last.type?(:number) || last.type?(:reserved_label)
        elsif first.type?(:memory_segment)
          last.type?(:number)
        end
      end
    end

    class Pop      < CommandWithDoubleOperands
      def valid_operand_types?
        if first.type?(:constant)
          last.type?(:number) || last.type?(:reserved_label)
        elsif first.type?(:memory_segment)
          last.type?(:number)
        end
      end
    end

    class Function < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:symbol) && last.type?(:number)
      end
    end

    class Call     < CommandWithDoubleOperands
      def valid_operand_types?
        first.type?(:symbol) && last.type?(:number)
      end
    end
  end
end

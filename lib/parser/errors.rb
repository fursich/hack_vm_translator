module Parser
  class ParseError              < VMTranslator::Error; end
  class UndefinedCommandPattern < ParseError; end
  class InvalidCommandName      < ParseError; end
  class InvalidOperandName      < ParseError; end

  class InvalidOperands         < ParseError; end
  class InvalidOperandSize      < InvalidOperands; end
  class InvalidOperandType      < InvalidOperands; end
end

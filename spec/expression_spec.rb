require_relative '../expression.rb'
require 'spec_helper'

describe Expression do
  let(:expression) { Expression.new("( 2 + ( ( 4 + 6 ) * (9 * 2) - ( 5 - 1)))") }

  context "#loop_handle" do
    it "updates expression content" do
      expression = Expression.new("(1+2)")
      
      expression.loop_handle
      expect(expression.content).to eq('3.0')
    end

    it "should call final check" do
      expression.content = "1+2"
      expect(expression).to receive(:final_check)

      expression.loop_handle     
    end
  end

  context "#calculate" do
    it "runs the simpliest sub formula: 1*2 = 2" do
      expect(expression.calculate('(1*2)')).to eq(2)
    end

    it "runs the simpliest sub formula: 1+2 = 3" do
      expect(expression.calculate('(1+2)')).to eq(3)
    end
    
    it "runs the simpliest sub formula: 1/2 = 0.5" do
      expect(expression.calculate('(1/2)')).to eq(0.5)
    end
    
    it "runs the simpliest sub formula: 2-1 = 1" do
      expect(expression.calculate('(2-1)')).to eq(1)
    end

    it "runs the simpliest sub formula: 2-1*5 = -3" do
      expect(expression.calculate('(2-1*5)')).to eq(-3)
    end
  end

  context "#handle_math_formula" do
    it "calculates the sqrt" do
      expression.content = "sqrt(4)"

      expression.handle_math_formula
      expect(expression.content).to eq('2.0')

    end
  end

  context "#update_expression" do
    it "updates the expression with its result" do
      expression.content = "(matched_formula)"
      allow(expression).to receive(:calculate).with('(matched_formula)').and_return('5')

      expression.update_expression('(matched_formula)')
      expect(expression.content).to eq('5')      
    end
  end

  context "#compute" do
    it "should invoke correct handler when formula is: 1+2" do
      formula = "1+2"
      allow(expression).to receive(:handle_operation)

      expression.compute(formula)
      expect(expression).to have_received(:handle_operation).with("1+2", '+')
    end

    it "should invoke correct handler when formula is: 2-1" do
      formula = "2-1"
      allow(expression).to receive(:handle_operation)

      expression.compute(formula)
      expect(expression).to have_received(:handle_operation).with("2-1", '-')
    end

    it "should invoke correct handler when formula is: 1*2" do
      formula = "1*2"
      allow(expression).to receive(:handle_operation)

      expression.compute(formula)
      expect(expression).to have_received(:handle_operation).with("1*2", '*')
    end

    it "should invoke correct handler when formula is: 1/2" do
      formula = "1/2"
      allow(expression).to receive(:handle_operation)

      expression.compute(formula)
      expect(expression).to have_received(:handle_operation).with("1/2", '/')
    end
  end

  context "#handle_operation" do
    it "should compute the result for 1+2" do
      formula,operator = "1+2", '+'

      expect(expression.handle_operation(formula,operator)).to eq(3)      
    end

    it "should compute the result for 2-1" do
      formula,operator = "2-1", '-'

      expect(expression.handle_operation(formula,operator)).to eq(1)      
    end

    it "should compute the result for 2*1" do
      formula,operator = "2*1", '*'

      expect(expression.handle_operation(formula,operator)).to eq(2)      
    end

    it "should compute the result for 2/1" do
      formula,operator = "2/1", '/'

      expect(expression.handle_operation(formula,operator)).to eq(2)      
    end

    it "should compute the result for 2/1" do
      formula,operator = "2/1", '/'

      expect(expression.handle_operation(formula,operator)).to eq(2)      
    end

    it "should compute the result for 1+2/1" do
      formula,operator = "1+2/1", '+'

      expect(expression.handle_operation(formula,operator)).to eq(3)     
    end

    it "should compute the result for 5-3*1" do
      formula,operator = "5-3*1", '-'
      expect(expression.handle_operation(formula,operator)).to eq(2)     
    end
  end

  context "#include_sign?" do
    it "should return true" do
      string = "1+1"

      expect(expression.include_sign?(string)).to be_truthy
    end

    it "should return false" do
      string = "11"

      expect(expression.include_sign?(string)).to be_falsey
    end

    it "should return true when string is '1+1'" do
      string = "1+1"

      expect(expression.include_sign?(string)).to be_truthy
    end

    it "should return true when string is '1-1'" do
      string = "1-1"

      expect(expression.include_sign?(string)).to be_truthy
    end

    it "should return true when string is '1*1'" do
      string = "1*1"

      expect(expression.include_sign?(string)).to be_truthy
    end

    it "should return true when string is '1/1'" do
      string = "1/1"

      expect(expression.include_sign?(string)).to be_truthy
    end

    it "should return false when there is no sign" do
      string = "11"

      expect(expression.include_sign?(string)).to be_falsey
    end
  end

  context "#include_unmatched_brackets?" do
    it "should return true when there is only one '('" do
      string = '(123'
      expect(expression.include_unmatched_brackets?(string)).to be_truthy
    end
    it "should return true when there is only one ')'" do
      string = '123)'
      expect(expression.include_unmatched_brackets?(string)).to be_truthy
    end
  end

  context "#include_invalid_character?" do
    it "should return true when there is only one '1.abd'" do
      string = '1.abd'
      expect(expression.include_invalid_character?(string)).to be_truthy
    end
    it "should return true when there is only one 'abc$'" do
      string = 'abd$'
      expect(expression.include_invalid_character?(string)).to be_truthy
    end
    it "shold return false when the string is a number look: '11.0'" do
      string = '11.0'
      expect(expression.include_invalid_character?(string)).to be_falsey
    end
    it "shold return false when the string is a number look: '111'" do
      string = '111'
      expect(expression.include_invalid_character?(string)).to be_falsey
    end
  end

  context "#final_check" do
    it "should raise an UnmatchedBracketsException when there is unmatched brackets" do
      expression.content = "(123"

      expect { expression.final_check }.to raise_error(UnmatchedBracketsException)
    end

    it "should raise an InvalidInputException when there is invalid inputs" do
      expression.content = "1+abc"

      expect { expression.final_check }.to raise_error(InvalidInputException)
    end

    it "should call one more time update_expression when there is sign in the content" do
      expression.content = "1+2"
      allow(expression).to receive(:update_expression)

      expression.final_check
      expect(expression).to have_received(:update_expression)
    end

  end

  context "get_float" do
    it "should convert a valid number-look string to float" do
      string = "1.55"

      expect(expression.get_float(string)).to eq(1.55)
    end

    it "doesn't convert an invalid number-look string to float" do
      string = "1.55a"

      expect { expression.get_float(string)}.to raise_error(InvalidInputException)
    end
  end

  context "#run" do
    it "should get correct final result for: ( 2 + ( ( 4 + 6 ) * (9 * 2) - ( 5 - 1)))" do
      expression = expression = Expression.new("( 2 + ( ( 4 + 6 ) * (9 * 2) - ( 5 - 1)))")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("The result is: 178.0")       
    end

    it "should get correct final result for: ( 2 + ( ( 4 + 6 ) * sqrt(5)) / 2 )" do
      expression = Expression.new("( 2 + ( ( 4 + 6 ) * sqrt(5)) / 2 )")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("The result is: 13.180339887498949")
    end

    it "should get correct final result for: 2 + ( ( 4 + 6 ) * (9 * ( 2 + 5 - 1)))" do
      expression = Expression.new("2 + ( ( 4 + 6 ) * (9 * ( 2 + 5 - 1)))")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("The result is: 542.0")
    end

    it "should get correct final result for: ((2 + ( ( 4 + 6 ) * (9 * ( 2 + 5 - 1)))" do
      expression = Expression.new("((2 + ( ( 4 + 6 ) * (9 * ( 2 + 5 - 1)))")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("There are unmatched brackets in your expression, please input a well-formatted expression.")
    end

    it "should get correct final result for: (1+2" do
      expression = Expression.new("(1+2")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("There are unmatched brackets in your expression, please input a well-formatted expression.")
    end

    it "should get correct final result for: abc+1" do
      expression = Expression.new("abc+1")
      allow(STDOUT).to receive(:puts)

      expression.run
      expect(STDOUT).to have_received(:puts).with("Your input is invalid, please input a well-formatted expression.")
    end
  end

end
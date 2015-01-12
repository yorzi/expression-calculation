require_relative './exception.rb'

class Expression
  attr_accessor :content

  def initialize(input)
    @content = input.gsub(/\s/, '')
  end

  def run
    handle_math_formula

    begin
      loop_handle
      puts "The result is: #{content}"
    rescue Exception => e
      puts e.message
    end
  end

  def loop_handle
    match = content.match(/\((\d+[*+-\/])+\d+\)/)
    if match && match[0]
      update_expression(match[0])
      loop_handle
    else
      final_check
    end
  end

  def final_check
    if include_unmatched_brackets?(content)
      raise UnmatchedBracketsException, "There are unmatched brackets in your expression, please input a well-formatted expression." 
    end

    update_expression(content) if include_sign?(content)

    raise InvalidInputException, "Your input is invalid, please input a well-formatted expression." if include_invalid_character?(content)
  end

  def calculate(formula)
    formula = formula.gsub('(','').gsub(')','')

    if formula.include?('sqrt')
      Math.send(:sqrt, formula.gsub('sqrt', '').to_f)
    else
      compute(formula)
    end
  end

  def compute(formula)
    if formula.include?('+')
      handle_operation(formula, '+')
    elsif formula.include?('-')
      handle_operation(formula, '-')
    elsif formula.include?('/')
      handle_operation(formula, '/')
    elsif formula.include?('*')
      handle_operation(formula, '*')
    end
  end

  def handle_operation(formula, operator)
    array = formula.split(operator)
    first = include_sign?(array[0]) ? compute(array[0]) : get_float(array[0])
    second = include_sign?(array[1]) ? compute(array[1]) : get_float(array[1])
    first.send(operator.to_sym, second)
  end

  def get_float(string)
    unless include_invalid_character?(string)
      string.to_f 
    else
      raise InvalidInputException, "Your input is invalid, please input a well-formatted expression."
    end
  end

  def include_sign?(string)
    string.include?('+') || string.include?('-') || string.include?('*') || string.include?('/')
  end

  def include_unmatched_brackets?(string)
    string.include?('(') || string.include?(')')
  end

  def include_invalid_character?(string)
    string !~ /(^\d+.\d+$|^\d+$)/
  end
  
  def handle_math_formula
    match = content.match(/(sqrt)\(\d+\)/)   
    if match && match[0]
      update_expression(match[0])
      handle_math_formula
    end
  end

  def update_expression(match)
    value = calculate(match)
    content.gsub!(match, value.to_s)
  end
end
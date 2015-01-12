require './expression.rb'

print "Hint: press Ctrl-C to break out of program execution. \n"

while true
  print "Please enter your formula: "
  formula = gets.chomp

  expression = Expression.new(formula)
  expression.run
end
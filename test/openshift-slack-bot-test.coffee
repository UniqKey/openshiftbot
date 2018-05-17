Calculator = require '../calculator'

exports.CalculatorTest =

    'test can add two positive numbers': (test) ->
        calculator = new Calculator
        result = calculator.add 2, 3
        test.equal(result, 5)
        test.done()

    'test can handle negative number addition': (test) ->
        calculator = new Calculator
        result = calculator.add -10, 5
        test.equal(result,  -5)
        test.done()

    'test can subtract two positive numbers': (test) ->
        calculator = new Calculator
        result = calculator.subtract 10, 6
        test.equal(result, 4)
        test.done()

    'test can handle negative number subtraction': (test) ->
        calculator = new Calculator
        result = calculator.subtract 4, -6
        test.equal(result, 10)
        test.done()
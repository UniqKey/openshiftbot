add = require('../scripts/math').add
describe 'addition', ->
  it 'adds numbers', ->
    console.assert (add(2, 3) == 5)

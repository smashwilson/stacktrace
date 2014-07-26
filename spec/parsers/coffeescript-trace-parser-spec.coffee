{traceParser} = require '../../lib/trace-parser'
coffeeTracer = require '../../lib/parsers/coffeescript-trace-parser'
ts = require '../trace-fixtures'

describe 'coffeeTracer', ->
  describe 'recognition', ->

    it 'parses a trace from each CoffeeScript fixture', ->
      for f in Object.keys(ts.COFFEESCRIPT)
        result = traceParser(ts.COFFEESCRIPT[f], [coffeeTracer])
        expect(result.length > 0).toBe(true)

    it "doesn't parse a trace from any non-CoffeeScript fixture", ->
      for k in Object.keys(ts)
        if k isnt 'COFFEESCRIPT'
          for f in Object.keys(ts[k])
            result = traceParser(ts[k][f], [coffeeTracer])
            expect(result.length).toBe(0)

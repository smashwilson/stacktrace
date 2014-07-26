{traceParser} = require '../../lib/trace-parser'
rubyTracer = require '../../lib/parsers/ruby-trace-parser'
ts = require '../trace-fixtures'

describe 'rubyTracer', ->
  describe 'recognition', ->

    it 'parses a trace from each Ruby fixture', ->
      for f in Object.keys(ts.RUBY)
        result = traceParser(ts.RUBY[f], [rubyTracer])
        expect(result.length > 0).toBe(true)

    it "doesn't parse a trace from any non-Ruby fixture", ->
      for k in Object.keys(ts)
        if k isnt 'RUBY'
          for f in Object.keys(ts[k])
            result = traceParser(ts[k][f], [rubyTracer])
            expect(result.length).toBe(0)

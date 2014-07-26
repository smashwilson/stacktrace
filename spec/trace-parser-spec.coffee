{traceParser} = require '../lib/trace-parser'

describe 'traceParser', ->
  describe 'with no traces', ->
    it 'returns an empty array', ->
      expect(traceParser('')).toEqual([])

{Stacktrace} = require '../lib/stacktrace'
{RUBY_TRACE} = require './trace-fixtures'

describe 'Stacktrace', ->
  describe 'with a Ruby trace', ->
    [trace, checksum] = []

    beforeEach ->
      trace = Stacktrace.parse(RUBY_TRACE)
      checksum = '3e325af231517f1e4fbe80f70c2c95296250ba80dc4de90bd5ac9c581506d9a6'

    describe 'preparation', ->
      it 'trims leading and trailing whitespace from each raw line', ->
        lines = (frame.rawLine for frame in trace.frames)
        expected = [
          "/home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)"
          "from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'"
          "from entry.rb:7:in `toplevel'"
          "from entry.rb:10:in `<main>'"
        ]
        expect(lines).toEqual(expected)

    describe 'parsing a Ruby stack trace', ->
      it 'parses the error message', ->
        expect(trace.message).toBe('Oh shit (RuntimeError)')

      it 'parses file paths from each frame', ->
        filePaths = (frame.path for frame in trace.frames)
        expected = [
          '/home/smash/tmp/tracer/dir/file1.rb'
          '/home/smash/tmp/tracer/otherdir/file2.rb'
          'entry.rb'
          'entry.rb'
        ]
        expect(filePaths).toEqual(expected)

      it 'parses line numbers from each frame', ->
        lineNumbers = (frame.lineNumber for frame in trace.frames)
        expected = [3, 5, 7, 10]
        expect(lineNumbers).toEqual(lineNumbers)

      it 'parses function names from each frame', ->
        functionNames = (frame.functionName for frame in trace.frames)
        expected = [
          'innerfunction'
          'outerfunction'
          'toplevel'
          '<main>'
        ]
        expect(functionNames).toEqual(expected)

    describe 'registration', ->
      afterEach ->
        Stacktrace.clearRegistry()

      it 'computes the SHA256 checksum of the normalized trace', ->
        expect(trace.getChecksum()).toBe(checksum)

      it 'generates a unique URL', ->
        url = "stacktrace://trace/#{checksum}"
        expect(trace.getUrl()).toBe(url)

      it 'can be registered in a global map', ->
        trace.register()
        expect(Stacktrace.forUrl(trace.getUrl())).toBe(trace)

      it 'can be unregistered cleanly', ->
        trace.register()
        expect(Stacktrace.forUrl(trace.getUrl())).toBe(trace)
        trace.unregister()
        expect(Stacktrace.forUrl(trace.getUrl())).toBeUndefined()

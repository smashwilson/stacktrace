{Stacktrace} = require '../lib/stacktrace'
{RUBY: {FUNCTION: TRACE}} = require './trace-fixtures'

describe 'Stacktrace', ->
  describe 'with a Ruby trace', ->
    [trace, checksum] = []

    beforeEach ->
      trace = Stacktrace.parse(TRACE)
      checksum = '9528763b5ab8ef052e2400e39d0f32dbe59ffcd06f039adc487f4f956511691f'

    describe 'preparation', ->
      it 'trims leading and trailing whitespace from each raw line', ->
        lines = (frame.rawLine for frame in trace.frames)
        expected = [
          "/home/smash/samples/tracer/otherdir/file2.rb:6:in `block in outerfunction': whoops (RuntimeError)"
          "from /home/smash/samples/tracer/dir/file1.rb:3:in `innerfunction'"
          "from /home/smash/samples/tracer/otherdir/file2.rb:5:in `outerfunction'"
          "from /home/smash/samples/tracer/entry.rb:7:in `toplevel'"
          "from /home/smash/samples/tracer/entry.rb:10:in `<main>'"
        ]
        expect(lines).toEqual(expected)

    describe 'parsing a Ruby stack trace', ->
      it 'parses the error message', ->
        expect(trace.message).toBe('whoops (RuntimeError)')

      it 'parses file paths from each frame', ->
        filePaths = (frame.path for frame in trace.frames)
        expected = [
          '/home/smash/samples/tracer/otherdir/file2.rb'
          '/home/smash/samples/tracer/dir/file1.rb'
          '/home/smash/samples/tracer/otherdir/file2.rb'
          '/home/smash/samples/tracer/entry.rb'
          '/home/smash/samples/tracer/entry.rb'
        ]
        expect(filePaths).toEqual(expected)

      it 'parses line numbers from each frame', ->
        lineNumbers = (frame.lineNumber for frame in trace.frames)
        expected = [6, 3, 5, 7, 10]
        expect(lineNumbers).toEqual(lineNumbers)

      it 'parses function names from each frame', ->
        functionNames = (frame.functionName for frame in trace.frames)
        expected = [
          'block in outerfunction'
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

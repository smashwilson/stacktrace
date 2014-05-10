{Stacktrace} = require '../lib/stacktrace'

TRACE = """
        /home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)
          from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'
          from entry.rb:7:in `toplevel'
          from entry.rb:10:in `<main>'
        """

describe 'Stacktrace', ->
  describe 'preparation', ->
    [trace] = []

    beforeEach ->
      trace = Stacktrace.parse(TRACE)

    it 'trims leading and trailing whitespace from each line', ->
      lines = (frame.line for frame in trace.frames)
      expected = [
        "/home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)",
        "from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'",
        "from entry.rb:7:in `toplevel'",
        "from entry.rb:10:in `<main>'"
      ]
      expect(lines).toEqual(expected)

    it 'computes the SHA256 checksum of the normalized trace'

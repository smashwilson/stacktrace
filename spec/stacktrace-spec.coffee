{Stacktrace} = require '../lib/stacktrace'
{RUBY_TRACE: TRACE} = require './trace-fixtures'

describe 'Stacktrace', ->
  describe 'preparation', ->
    [trace, checksum] = []

    beforeEach ->
      trace = Stacktrace.parse(TRACE)
      checksum = '3e325af231517f1e4fbe80f70c2c95296250ba80dc4de90bd5ac9c581506d9a6'

    it 'trims leading and trailing whitespace from each raw line', ->
      lines = (frame.rawLine for frame in trace.frames)
      expected = [
        "/home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)",
        "from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'",
        "from entry.rb:7:in `toplevel'",
        "from entry.rb:10:in `<main>'"
      ]
      expect(lines).toEqual(expected)

    it 'computes the SHA256 checksum of the normalized trace', ->
      expect(trace.getChecksum()).toBe(checksum)

    it 'generates a unique URL', ->
      url = "stacktrace://trace/#{checksum}"
      expect(trace.getUrl()).toBe(url)

    it 'parses a Ruby stack trace', ->

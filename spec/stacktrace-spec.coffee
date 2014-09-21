{Point} = require 'atom'
path = require 'path'

{Stacktrace, Frame} = require '../lib/stacktrace'
{RUBY: {FUNCTION: TRACE}} = require './trace-fixtures'

describe 'Stacktrace', ->
  describe 'with a Ruby trace', ->
    [trace, checksum] = []

    beforeEach ->
      [trace] = Stacktrace.parse(TRACE)
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
        filePaths = (frame.realPath for frame in trace.frames)
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

      it 'assigns an index to each frame', ->
        positions = (frame.index for frame in trace.frames)
        expect(positions).toEqual([0..4])

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

    describe 'activation', ->
      afterEach ->
        activated = Stacktrace.getActivated()
        activated.deactivate() if activated?

      it 'can be activated', ->
        trace.activate()
        expect(Stacktrace.getActivated()).toBe(trace)

      it 'can be deactivated if activated', ->
        trace.activate()
        trace.deactivate()
        expect(Stacktrace.getActivated()).toBeNull()

      it 'can be deactivated even if not activated', ->
        trace.deactivate()
        expect(Stacktrace.getActivated()).toBeNull()

      it 'broadcasts an onDidChangeActive event', ->
        event = null
        Stacktrace.onDidChangeActive (e) -> event = e

        trace.activate()
        expect(event.oldTrace).toBeNull()
        expect(event.newTrace).toBe(trace)

    describe 'walking up and down the stack', ->

      it 'links to the callee of each frame', ->
        callees = (trace.calledFrom(f) for f in trace.frames)
        expected = [
          undefined
          trace.frames[0]
          trace.frames[1]
          trace.frames[2]
          trace.frames[3]
        ]
        expect(callees).toEqual(expected)

      it 'links to the caller of each frame', ->
        callers = (trace.callerOf(f) for f in trace.frames)
        expected = [
          trace.frames[1]
          trace.frames[2]
          trace.frames[3]
          trace.frames[4]
          undefined
        ]
        expect(callers).toEqual(expected)

    describe 'active frame location', ->

      it 'locates the frame corresponding to an Editor position', ->
        frame = trace.atEditorPosition
          position: Point.fromObject([4, 0])
          path: '/home/smash/samples/tracer/otherdir/file2.rb'

        expect(frame).toBe(trace.frames[2])
        expect(frame.humanIndex()).toBe(3)

      it 'returns null if none are found', ->
        frame = trace.atEditorPosition
          position: Point.fromObject([2, 1])
          path: '/home/smash/samples/tracer/otherdir/file2.rb'

        expect(frame).toBeNull()

describe 'Frame', ->
  [frame, fixturePath] = []

  beforeEach ->
    fixturePath = path.join __dirname, 'fixtures', 'context.txt'
    frame = new Frame('five', fixturePath, 5, 'something')

  it 'acquires n lines of context asynchronously', ->
    lines = null

    frame.getContext 2, (err, ls) ->
      throw err if err?
      lines = ls

    waitsFor -> lines?

    runs ->
      expect(lines.length).toBe(5)
      expect(lines[0]).toEqual('three')
      expect(lines[1]).toEqual('  four')
      expect(lines[2]).toEqual('five')
      expect(lines[3]).toEqual('six')
      expect(lines[4]).toEqual('')

  describe 'recognizes itself in an Editor', ->
    it 'is on a cursor', ->
      expect(frame.isOn(position: Point.fromObject([4, 0]), path: fixturePath)).toBeTruthy()

    it 'is not on a cursor', ->
      expect(frame.isOn(position: Point.fromObject([2, 0]), path: fixturePath)).toBeFalsy()

    it 'is on a different file', ->
      expect(frame.isOn(position: Point.fromObject([4, 0]), path: 'some/other/path.rb')).toBeFalsy()

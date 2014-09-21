fs = require 'fs'

{Emitter} = require 'event-kit'

jsSHA = require 'jssha'
{chomp} = require 'line-chomper'
traceParser = null

PREFIX = 'stacktrace://trace'

REGISTRY = {}
ACTIVE = null

emitter = new Emitter

# Internal: A heuristically parsed and interpreted stacktrace.
#
class Stacktrace

  constructor: (@frames = [], @message = '') ->
    i = 0
    for f in @frames
      f.index = i
      i += 1

  # Internal: Compute the SHA256 checksum of the normalized stacktrace.
  #
  getChecksum: ->
    body = (frame.rawLine for frame in @frames).join()
    sha = new jsSHA(body, 'TEXT')
    sha.getHash('SHA-256', 'HEX')

  # Internal: Generate a URL that can be used to launch or focus a
  # {StacktraceView}.
  #
  getUrl: -> @url ?= "#{PREFIX}/#{@getChecksum()}"

  # Public: Determine whether or not this Stacktrace is the "active" one. The active Stacktrace is
  # shown in a bottom navigation panel and highlighted in opened editors.
  #
  isActive: -> false

  # Internal: Register this trace in a global map by its URL.
  #
  register: ->
    REGISTRY[@getUrl()] = this

  # Internal: Remove this trace from the global map if it had previously been
  # registered.
  #
  unregister: ->
    delete REGISTRY[@getUrl()]

  # Public: Mark this trace as the "active" one. The active trace is shown in the navigation view
  # and its frames are given a marker in an open {EditorView}.
  #
  activate: ->
    former = ACTIVE
    ACTIVE = this
    if former isnt ACTIVE
      emitter.emit 'did-change-active', oldTrace: former, newTrace: ACTIVE

  # Public: Deactivate this trace if it's active.
  #
  deactivate: ->
    if ACTIVE is this
      ACTIVE = null
      emitter.emit 'did-change-active', oldTrace: this, newTrace: null

  # Public: Return the Frame corresponding to an Editor position, if any, along with its position
  # within the trace.
  #
  # object - "position" should be a Point corresponding to a cursor position, and "path" the full
  #          path of an Editor.
  #
  atEditorPosition: (editorPosition) ->
    [index, total] = [1, @frames.length]
    for frame in @frames
      return frame if frame.isOn editorPosition
      index += 1
    return null

  # Public: Return the Frame that called the given Frame, or undefined if given the top of the stack.
  #
  # frame - The current Frame to use as a reference point.
  #
  callerOf: (frame) -> @frames[frame.index + 1]

  # Public: Return the Frame that a given Frame called into, or undefined if given the bottom of the
  # stack.
  #
  # frame - The current Frame to use as a reference point.
  #
  calledFrom: (frame) -> @frames[frame.index - 1]

  # Public: Subscribe to be notified when the active Stacktrace is set or cleared.
  #
  # callback - The callback to invoke with the oldTrace and newTrace.
  #
  # Returns a Disposable to cancel a subscription.
  #
  @onDidChangeActive: (callback) ->
    emitter.on 'did-change-active', callback

  # Public: Parse zero to many Stacktrace instances from a corpus of text.
  #
  # text - A raw blob of text.
  #
  @parse: (text) ->
    {traceParser} = require('./trace-parser') unless traceParser?
    traceParser(text)

  # Internal: Return a registered trace, or null if none match the provided
  # URL.
  #
  @forUrl: (url) ->
    REGISTRY[url]

  # Internal: Clear the global trace registry.
  #
  @clearRegistry: ->
    REGISTRY = {}

  # Public: Retrieve the currently activated {Stacktrace}, or null if no trace is active.
  #
  @getActivated: -> ACTIVE

# Public: A single stack frame within a {Stacktrace}.
#
class Frame

  constructor: (@rawLine, @rawPath, @lineNumber, @functionName) ->
    @index = null
    @realPath = @rawPath

  # Public: Return the zero-indexed line number.
  #
  bufferLineNumber: -> @lineNumber - 1

  # Public: Return the one-based frame index.
  #
  humanIndex: -> @index + 1

  # Public: Asynchronously collect n lines of context around the specified line number in this
  # frame's source file.
  #
  # n        - The number of lines of context to collect on *each* side of the error line. The error
  #            line will always be `lines[n]` and `lines.length` will be `n * 2 + 1`.
  # callback - Invoked with any errors or an Array containing the relevant lines.
  #
  getContext: (n, callback) ->
    # Notice that @lineNumber is one-indexed, not zero-indexed.
    range =
      fromLine: @lineNumber - n - 1
      toLine: @lineNumber + n
      trim: false
      keepLastEmptyLine: true
    chomp fs.createReadStream(@realPath), range, callback

  navigateTo: ->
    position = [@lineNumber - 1, 0]
    promise = atom.workspace.open @realPath, initialLine: position[0]
    promise.then (editor) ->
      editor.setCursorBufferPosition position
      editor.scrollToBufferPosition position, center: true

  # Public: Return true if the buffer position and path correspond to this Frame's line.
  #
  isOn: ({position, path}) ->
    path is @realPath and position.row is @bufferLineNumber()


module.exports =
  PREFIX: PREFIX
  Stacktrace: Stacktrace
  Frame: Frame

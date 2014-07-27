fs = require 'fs'
jsSHA = require 'jssha'
{chomp} = require 'line-chomper'
traceParser = null

PREFIX = 'stacktrace://trace'

REGISTRY = {}
ACTIVE = null

# Internal: A heuristically parsed and interpreted stacktrace.
#
class Stacktrace

  constructor: (@frames = [], @message = '') ->

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
  activate: -> ACTIVE = this

  # Public: Deactivate this trace if it's active.
  #
  deactivate: -> ACTIVE = null if ACTIVE is this

  # Public: Parse zero to many Stacktrace instances from a corpus of text.
  #
  # text - A raw blob of text.
  #
  @parse: (text) ->
    {traceParser} = require('./trace-parser') unless traceParser?
    traceParser(text)

  # Internal: Return a registered trace, or null if none match the provided
  # URL.
  @forUrl: (url) ->
    REGISTRY[url]

  # Internal: Clear the global trace registry.
  @clearRegistry: ->
    REGISTRY = {}

  # Public: Retrieve the currently activated {Stacktrace}, or null if no trace is active.
  #
  @getActivated: -> ACTIVE

# Public: A single stack frame within a {Stacktrace}.
#
class Frame

  constructor: (@rawLine, @rawPath, @lineNumber, @functionName) ->
    @realPath = @rawPath

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
      for ev in atom.workspaceView.getEditorViews()
        editorView = ev if ev.getEditor() is editor
      if editorView?
        editorView.scrollToBufferPosition position, center: true


module.exports =
  PREFIX: PREFIX
  Stacktrace: Stacktrace
  Frame: Frame

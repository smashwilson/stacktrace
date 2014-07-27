fs = require 'fs'
jsSHA = require 'jssha'
{chomp} = require 'line-chomper'
traceParser = null

PREFIX = 'stacktrace://trace'

REGISTRY = {}

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
    range =
      fromLine: @lineNumber - n
      toLine: @lineNumber + n + 1
    chomp fs.createReadStream(@realPath), range, callback

module.exports =
  PREFIX: PREFIX
  Stacktrace: Stacktrace
  Frame: Frame

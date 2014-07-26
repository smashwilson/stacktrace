jsSHA = require 'jssha'
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

# Internal: A single stack frame within a {Stacktrace}.
#
class Frame

  constructor: (@rawLine, @path, @lineNumber, @functionName) ->

module.exports =
  PREFIX: PREFIX
  Stacktrace: Stacktrace
  Frame: Frame

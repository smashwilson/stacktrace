jsSHA = require 'jssha'

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

  @parse: (text) ->
    frames = []
    for rawLine in text.split(/\r?\n/)
      f = parseRubyFrame(rawLine)
      frames.push f if f?
    new Stacktrace(frames, frames[0].message)

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


# Internal: Parse a Ruby stack frame. This is a simple placeholder until I
# put together a class hierarchy to handle frame recognition and parsing.
#
parseRubyFrame = (rawLine) ->
  m = rawLine.trim().match /// ^
    (?:from \s+)?  # On all lines but the first
    ([^:]+) :  # File path
    (\d+) :    # Line number
    in \s* ` ([^']+) ' # Function name
    (?: : \s (.*))? # Error message, only on the first
  ///

  if m?
    [raw, path, lineNumber, functionName, message] = m
    new Frame(raw, path, lineNumber, functionName, message)

module.exports =
  PREFIX: PREFIX
  Stacktrace: Stacktrace
  Frame: Frame

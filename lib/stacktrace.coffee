jsSHA = require 'jssha'

# Internal: A heuristically parsed and interpreted stacktrace.
class Stacktrace

  constructor: (@frames = []) ->

  # Internal: Compute the SHA256 checksum of the normalized stacktrace.
  getChecksum: ->
    body = (frame.rawLine for frame in @frames).join()
    sha = new jsSHA(body, 'TEXT')
    sha.getHash('SHA-256', 'HEX')

  # Internal: Generate a URL that can be used to launch or focus a
  # {StacktraceView}.
  getUrl: -> @url ?= "stacktrace://trace/#{@getChecksum()}"

  @parse: (text) ->
    frames = (Frame.parse(rawLine) for rawLine in text.split(/\r?\n/))
    new Stacktrace(frames)

# Internal: A single stack frame within a {Stacktrace}.
class Frame

  constructor: (@rawLine) ->

  @parse: (rawLine) ->
    # Normalize leading and trailing whitespace.
    new Frame(rawLine.trim())

module.exports =
  Stacktrace: Stacktrace
  Frame: Frame

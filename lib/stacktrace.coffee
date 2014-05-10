jsSHA = require 'jssha'

# Internal: A heuristically parsed and interpreted stacktrace.
class Stacktrace

  constructor: (@frames = []) ->

  # Internal: Compute the SHA256 checksum of the normalized stacktrace.
  getChecksum: ->
    body = (frame.line for frame in @frames).join()
    sha = new jsSHA(body, 'TEXT')
    sha.getHash('SHA-256', 'HEX')

  # Internal: Generate a URL that can be used to launch or focus a
  # {StacktraceView}.
  getUrl: -> @url ?= "stacktrace://trace/#{@getChecksum()}"

  @parse: (text) ->
    frames = (Frame.parse(line) for line in text.split(/\r?\n/))
    new Stacktrace(frames)

# Internal: A single stack frame within a {Stacktrace}.
class Frame

  constructor: (@line) ->

  @parse: (line) ->
    # Normalize leading and trailing whitespace.
    new Frame(line.trim())

module.exports =
  Stacktrace: Stacktrace
  Frame: Frame

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
    frames = (parseRubyFrame(rawLine) for rawLine in text.split(/\r?\n/))
    new Stacktrace(frames)

# Internal: A single stack frame within a {Stacktrace}.
class Frame

  constructor: (@rawLine, @path, @lineNumber, @functionName) ->

# Internal: Parse a Ruby stack frame. This is a simple placeholder until I
# put together a class hierarchy to handle frame recognition and parsing.
parseRubyFrame = (rawLine) ->
  [raw, path, lineNumber, functionName, message] = rawLine.trim().match /// ^
    (?:from \s+)?  # On all lines but the first
    ([^:]+) :  # File path
    (\d+) :    # Line number
    in \s* ` ([^']+) ' # Function name
    (?: : (.*))? # Error message, only on the first
  ///

  new Frame(raw, path, lineNumber, functionName)

module.exports =
  Stacktrace: Stacktrace
  Frame: Frame

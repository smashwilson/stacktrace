# Internal: A heuristically parsed and interpreted stacktrace.
class Stacktrace

  constructor: (@frames = []) ->

  @parse: (text) ->
    frames = (Frame.parse(line) for line in text.split(/\r?\n/))
    console.log frames
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

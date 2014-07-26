{Stacktrace, Frame} = require './stacktrace'
fs = require 'fs'
path = require 'path'

# Internal: Build a Frame instance with a simple DSL.
#
class FrameBuilder

  constructor: (@rawLine) ->
    [@path, @lineNumber, @functionName, @message] = null

  path: (@path) ->

  lineNumber: (@lineNumber) ->

  functionName: (@functionName) ->

  message: (@message) ->

# Internal: Use the collected information from a FrameBuilder to instantiate a Frame.
#
asFrame = (fb) ->
  required = [
    { name: 'rawLine', ok: fb.rawLine? }
    { name: 'path', ok: fb.path? }
    { name: 'lineNumber', ok: fb.lineNumber? }
    { name: 'functionName', ok: fb.functionName? }
  ]
  missing = (r.name for r in required when not r.ok)

  unless missing.length is 0
    e = new Error('Missing required frame attributes.')
    e.missing = missing
    e.rawLine = fb.rawLine
    throw e

  new Frame(fb.rawLine, fb.path, fb.lineNumber, fb.functionName, fb.message)

allTracers = null

# Internal: Load stacktrace parsers from the parsers/ directory.
#
loadTracers = ->
  allTracers = []
  parsersPath = path.resolve(__dirname, 'parsers')
  for parserFile in fs.readdirSync(parsersPath)
    allTracers.push require(path.join parsersPath, parserFile)

# Internal: Parse zero or more stacktraces from a sample of text.
#
# text    - String output sample that may contain one or more stacktraces from a
#           supported language.
# tracers - If provided, use only the provided tracer objects. Otherwise, everything in parsers/
#           will be loaded and used.
#
# Returns: An Array of Stacktrace objects, in the order in which they occurred
#   in the original sample.
#
traceParser = (text, tracers = null) ->
  unless tracers?
    loadTracers() unless allTracers?
    tracers = allTracers

  stacks = []
  frames = []
  message = null
  activeTracer = null

  finishStacktrace = ->
    s = new Stacktrace(frames, message)
    stacks.push s

    frames = []
    message = null
    activeTracer = null

  for rawLine in text.split(/\r?\n/)
    trimmed = rawLine.trim()

    # Mid-stack frame.
    if activeTracer?
      fb = new FrameBuilder(trimmed)
      activeTracer.consume fb,
        emitMessage: (m) -> message = m
        emitFrame: -> frames.push asFrame fb
        emitStack: finishStacktrace

    # Outside of a frame. Attempt to recognize the next trace by emitting at least one frame.
    unless activeTracer?
      for t in tracers
        t.recognize fb,
          emitMessage: (m) -> message = m
          emitFrame: -> frames = [asFrame(fb)]
          emitStack: finishStacktrace
        if message? or frames.length > 0
          activeTracer = t
          break

  stacks

module.exports =
  traceParser: traceParser

{View} = require 'atom'
{Stacktrace, PREFIX} = require './stacktrace'

class StacktraceView extends View

  @content: (trace) ->
    @div class: 'stacktrace tool-panel padded', =>
      @div class: 'header panel', =>
        @h2 trace.message
      @div class: 'frames', =>
        for frame in trace.frames
          @subview 'frame', new FrameView(frame)

  initialize: (@trace) ->

  # Internal: Return the window title.
  getTitle: ->
    @trace.message

  # Internal: Register an opener function in the workspace to handle URLs
  # generated by a Stacktrace.
  @registerIn: (workspace) ->
    workspace.registerOpener (filePath) ->
      trace = Stacktrace.forUrl(filePath)
      new StacktraceView(trace) if trace?


class FrameView extends View

  @content: (frame) ->
    @div class: 'frame inset-panel', =>
      @div class: 'panel-heading', =>
        @span class: 'function-name text-highlight inline-block', frame.functionName
        @span class: 'source-location text-info inline-block pull-right', =>
          @text "#{frame.path} @ #{frame.lineNumber}"
      @div class: 'panel-body padded', =>
        @pre output: 'source', 'Source goes here'

  initialize: (@frame) ->

module.exports =
  StacktraceView: StacktraceView
  FrameView: FrameView
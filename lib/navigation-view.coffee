{View} = require 'atom'
{Subscriber} = require 'emissary'
{Stacktrace} = require './stacktrace'

class NavigationView extends View

  Subscriber.includeInto this

  @content: ->
    activatedClass = if Stacktrace.getActivated()? then '' else 'inactive'

    @div class: "tool-panel panel-bottom padded stacktrace navigation #{activatedClass}", =>
      @div class: 'inline-block trace-name', =>
        @h2 class: 'inline-block text-highlight message', outlet: 'message', click: 'backToTrace'
        @span class: 'inline-block icon icon-x', click: 'deactivateTrace'
      @div class: 'inline-block current-frame unfocused', outlet: 'frameContainer', =>
        @span class: 'inline-block icon icon-code'
        @span class: 'inline-block function', outlet: 'frameFunction'
        @span class: 'inline-block index', outlet: 'frameIndex'
        @span class: 'inline-block divider', '/'
        @span class: 'inline-block total', outlet: 'frameTotal'

  initialize: ->
    @subscribe Stacktrace, 'active-changed', (e) =>
      if e.newTrace? then @useTrace(e.newTrace) else @noTrace()

    # Subscribe to opening editors. Set the current frame when a cursor is moved over a frame's
    # line.
    atom.workspace.eachEditor (e) =>
      @subscribe e, 'cursors-moved', =>
        if @trace?
          pos =
            position: e.getCursorBufferPosition()
            path: e.getPath()

          # Allow the already-set @frame a chance to see if it still applies.
          # This lets the caller and called navigation work properly, even if multiple frames are
          # on the same line.
          unless @frame? and @frame.isOn(pos)

            # Otherwise, scan the trace for a matching frame.
            frame = @trace.atEditorPosition(pos)
            if frame? then @useFrame(frame) else @unfocusFrame()

    if Stacktrace.getActivated? then @hide()

  beforeRemove: ->
    @unsubscribe Stacktrace

  useTrace: (@trace) ->
    @removeClass 'inactive'
    @message.text(trace.message)
    @noFrame()
    @show()

  noTrace: ->
    @addClass 'inactive'
    @message.text('')
    @noFrame()
    @hide()

  useFrame: (@frame) ->
    @frameContainer.removeClass 'unfocused'
    @frameFunction.text @frame.functionName
    @frameFunction.addClass 'highlight-info'
    @frameIndex.text @frame.humanIndex().toString()
    @frameTotal.text @trace.frames.length.toString()

  unfocusFrame: ->
    @frameContainer.addClass 'unfocused'
    @frameFunction.removeClass 'highlight-info'

  noFrame: ->
    @unfocusFrame()
    @frameFunction.text ''
    @frameIndex.text ''
    @frameTotal.text ''

  deactivateTrace: ->
    Stacktrace.getActivated().deactivate()

  backToTrace: ->
    url = Stacktrace.getActivated()?.getUrl()
    atom.workspace.open(url) if url

  navigateToCaller: ->
    return unless @trace? and @frame?

    @trace.callerOf(@frame)?.navigateTo()

  navigateToCalled: ->
    return unless @trace? and @frame?

    @trace.calledFrom(@frame)?.navigateTo()

module.exports = NavigationView: NavigationView

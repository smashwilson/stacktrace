{View} = require 'atom'
{Subscriber} = require 'emissary'
{Stacktrace} = require './stacktrace'

class NavigationView extends View

  Subscriber.includeInto this

  @content: ->
    activatedClass = if Stacktrace.getActivated()? then '' else 'inactive'

    @div class: "tool-panel panel-bottom padded stacktrace navigation #{activatedClass}", =>
      @div class: 'trace-name', =>
        @h2 class: 'inline-block text-highlight message', outlet: 'message', click: 'backToTrace'
        @span class: 'inline-block icon icon-x', click: 'deactivateTrace'
      @div class: 'current-frame unfocused', outlet: 'frameContainer', =>
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
          frame = @trace.atPosition
            position: e.getCursorBufferPosition()
            path: e.getPath()
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

  useFrame: ({@frame, index, total}) ->
    @frameContainer.removeClass 'unfocused'
    @frameFunction.text @frame.functionName
    @frameIndex.text index.toString()
    @frameTotal.text total.toString()

  unfocusFrame: ->
    @frameContainer.addClass 'unfocused'

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

module.exports = NavigationView: NavigationView

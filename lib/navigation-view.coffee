{View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
{Stacktrace} = require './stacktrace'
{CompositeDisposable} = require 'event-kit'

class NavigationView extends View

  @content: ->
    activatedClass = if Stacktrace.getActivated()? then '' else 'inactive'

    @div class: "tool-panel panel-bottom padded stacktrace navigation #{activatedClass}", =>
      @div class: 'inline-block trace-name', =>
        @h2 class: 'inline-block text-highlight message', outlet: 'message', click: 'backToTrace'
        @span class: 'inline-block icon icon-x', click: 'deactivateTrace'
      @div class: 'inline-block current-frame unfocused', outlet: 'frameContainer', =>
        @span class: 'inline-block icon icon-code'
        @span class: 'inline-block function', outlet: 'frameFunction', click: 'navigateToLastActive'
        @span class: 'inline-block index', outlet: 'frameIndex'
        @span class: 'inline-block divider', '/'
        @span class: 'inline-block total', outlet: 'frameTotal'
      @div class: 'pull-right controls', =>
        @button class: 'inline-block btn', click: 'navigateToCaller', =>
          @span class: 'icon icon-arrow-up'
          @span 'Caller'
          @span class: 'text-info button-label-up', outlet: 'upButtonLabel'
        @button class: 'inline-block btn', click: 'navigateToCalled', =>
          @span class: 'text-info button-label-down', outlet: 'downButtonLabel'
          @span 'Follow Call'
          @span class: 'icon icon-arrow-down'

  initialize: ->
    @subs = new CompositeDisposable

    @subs.add Stacktrace.onDidChangeActive (e) =>
      if e.newTrace? then @useTrace(e.newTrace) else @noTrace()

    # Subscribe to opening editors. Set the current frame when a cursor is moved over a frame's
    # line.
    @subs.add atom.workspace.observeTextEditors (e) =>
      @updateTraceState(e)
      @subs.add e.onDidChangeCursorPosition => @updateTraceState(e)

    if Stacktrace.getActivated? then @hide()

    # Prepend keystroke glyphs to the up and down buttons.
    upBindings = atom.keymaps.findKeyBindings command: 'stacktrace:to-caller'
    if upBindings.length > 0
      binding = upBindings[0]
      @upButtonLabel.text _.humanizeKeystroke binding.keystrokes

    downBindings = atom.keymaps.findKeyBindings command: 'stacktrace:follow-call'
    if downBindings.length > 0
      binding = downBindings[0]
      @downButtonLabel.text _.humanizeKeystroke binding.keystrokes

  detached: ->
    @subs.dispose()

  updateTraceState: (editor) ->
    if @trace?
      pos =
        position: editor.getCursorBufferPosition()
        path: editor.getPath()

      # Allow the already-set @frame a chance to see if it still applies.
      # This lets the caller and called navigation work properly, even if multiple frames are
      # on the same line.
      if @frame? and @frame.isOn(pos)
        @useFrame(@frame)
      else
        # Otherwise, scan the trace for a matching frame.
        frame = @trace.atEditorPosition(pos)
        if frame? then @useFrame(frame) else @unfocusFrame()

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

    f = @trace.callerOf(@frame)
    if f?
      @frame = f
      @frame.navigateTo()

  navigateToCalled: ->
    return unless @trace? and @frame?

    f = @trace.calledFrom(@frame)
    if f?
      @frame = f
      @frame.navigateTo()

  navigateToLastActive: ->
    return unless @frame?
    @frame.navigateTo()

  @current: ->
    atom.workspaceView.find('.stacktrace.navigation')?.view()

module.exports = NavigationView: NavigationView

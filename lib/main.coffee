{CompositeDisposable} = require 'event-kit'

EnterDialog = require './enter-dialog'
{Stacktrace} = require './stacktrace'
{StacktraceView} = require './stacktrace-view'
{NavigationView} = require './navigation-view'
{decorate, cleanup} = require './editor-decorator'

subs = new CompositeDisposable()

module.exports =

  activate: (state) ->
    subs.add atom.commands.add 'atom-workspace',
      'stacktrace:paste': => atom.workspace.addTopPanel item: new EnterDialog(this)
      'stacktrace:from-selection': =>
        selections = atom.workspace.getActiveTextEditor()?.getSelections() or []
        text = (s.getText() for s in selections).join ''
        @traceHandlerV1().acceptTrace(text)
      'stacktrace:to-caller': -> NavigationView.current()?.navigateToCaller()
      'stacktrace:follow-call': -> NavigationView.current()?.navigateToCalled()

    subs.add atom.workspace.observeTextEditors decorate
    subs.add Stacktrace.onDidChangeActive (e) ->
      cleanup()
      if e.newTrace?
        decorate(e) for e in atom.workspace.getTextEditors()

    @navigationView = new NavigationView
    atom.workspace.addBottomPanel item: @navigationView

    subs.add StacktraceView.registerIn(atom.workspace)

  deactivate: ->
    @navigationView.remove()
    subs.dispose()

  # Public: Construct a service object that implements the stacktrace parsing service.
  #
  traceHandlerV1: ->

    # Public: Parse any and all stacktraces recognized from a sample of text. Open a new
    # StacktraceView for each.
    #
    # trace [String] - A sample of text that may contain zero to many stacktraces in recognized
    #  languages.
    #
    acceptTrace: (trace) ->
      for trace in Stacktrace.parse(trace)
        trace.register()
        atom.workspace.open trace.getUrl()

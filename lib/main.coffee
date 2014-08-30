EnterDialog = require './enter-dialog'
{Stacktrace} = require './stacktrace'
{StacktraceView} = require './stacktrace-view'
{NavigationView} = require './navigation-view'
{decorate, cleanup} = require './editor-decorator'

subs = []

module.exports =

  activate: (state) ->
    atom.workspaceView.command 'stacktrace:paste', ->
      atom.workspaceView.appendToTop new EnterDialog()

    atom.workspaceView.command 'stacktrace:from-selection', ->
      selections = atom.workspace.getActiveEditor()?.getSelections()
      text = (s.getText() for s in (selections or [])).join ''
      atom.emit 'stacktrace:accept-trace', trace: text

    atom.workspaceView.command 'stacktrace:to-caller', ->
      NavigationView.current()?.navigateToCaller()

    atom.workspaceView.command 'stacktrace:follow-call', ->
      NavigationView.current()?.navigateToCalled()

    subs.push atom.workspace.eachEditor decorate
    subs.push Stacktrace.on 'active-changed', (e) ->
      cleanup()
      if e.newTrace?
        decorate(e) for e in atom.workspace.getEditors()

    @navigationView = new NavigationView
    atom.workspaceView.appendToBottom @navigationView

    StacktraceView.registerIn(atom.workspace)

    subs.push atom.on 'stacktrace:accept-trace', ({trace}) =>
      for trace in Stacktrace.parse(trace)
        trace.register()
        atom.workspace.open trace.getUrl()

  deactivate: ->
    @navigationView.remove()

    sub.off() for sub in subs

EnterDialog = require './enter-dialog'
{Stacktrace} = require './stacktrace'
{StacktraceView} = require './stacktrace-view'
{NavigationView} = require './navigation-view'
editorDecorator = require './editor-decorator'

module.exports =

  activate: (state) ->
    atom.workspaceView.command 'stacktrace:paste', ->
      atom.workspaceView.appendToTop new EnterDialog()

    atom.workspaceView.command 'stacktrace:from-selection', ->
      selections = atom.workspace.getActiveEditor()?.getSelections()
      text = (s.getText() for s in (selections or [])).join ''
      atom.emit 'stacktrace:accept-trace', trace: text

    atom.workspace.eachEditor editorDecorator
    @activeChanged = Stacktrace.on 'active-changed', ->
      editorDecorator(e) for e in atom.workspace.getEditors()

    @navigationView = new NavigationView
    atom.workspaceView.appendToBottom @navigationView

    StacktraceView.registerIn(atom.workspace)

    @acceptTrace = atom.on 'stacktrace:accept-trace', ({trace}) =>
      for trace in Stacktrace.parse(trace)
        trace.register()
        atom.workspace.open trace.getUrl()

  deactivate: ->
    @navigationView.remove()

    @activeChanged.off()
    @acceptTrace.off()

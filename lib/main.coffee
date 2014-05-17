EnterDialog = require './enter-dialog'
{Stacktrace} = require './stacktrace'
{StacktraceView} = require './stacktrace-view'

module.exports =

  activate: (state) ->
    atom.workspaceView.command 'stacktrace:enter', ->
      atom.workspaceView.appendToTop new EnterDialog()

    StacktraceView.registerIn(atom.workspace)

    atom.on 'stacktrace:accept-trace', ({trace}) =>
      t = Stacktrace.parse(trace)
      t.register()
      atom.workspace.open t.getUrl()

  deactivate: ->
    atom.off 'stacktrace:accept-trace'

  serialize: ->

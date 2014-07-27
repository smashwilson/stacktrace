EnterDialog = require './enter-dialog'
{Stacktrace} = require './stacktrace'
{StacktraceView} = require './stacktrace-view'

module.exports =

  activate: (state) ->
    atom.workspaceView.command 'stacktrace:paste', ->
      atom.workspaceView.appendToTop new EnterDialog()

    StacktraceView.registerIn(atom.workspace)

    atom.on 'stacktrace:accept-trace', ({trace}) =>
      for trace in Stacktrace.parse(trace)
        trace.register()
        atom.workspace.open trace.getUrl()

  deactivate: ->
    atom.off 'stacktrace:accept-trace'

  serialize: ->

StacktraceView = require './stacktrace-view'

module.exports =
  stacktraceView: null

  activate: (state) ->
    @stacktraceView = new StacktraceView(state.stacktraceViewState)

  deactivate: ->
    @stacktraceView.destroy()

  serialize: ->
    stacktraceViewState: @stacktraceView.serialize()

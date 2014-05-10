EnterDialog = require './enter-dialog'

module.exports =

  activate: (state) ->
    atom.workspaceView.command 'stacktrace:enter', ->
      atom.workspaceView.appendToTop new EnterDialog()

  deactivate: ->

  serialize: ->

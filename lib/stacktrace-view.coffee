{View} = require 'atom'

module.exports =
class StacktraceView extends View
  @content: ->
    @div class: 'stacktrace overlay from-top', =>
      @div "The Stacktrace package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "stacktrace:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "StacktraceView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

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

  initialize: ->
    @subscribe Stacktrace, 'active-changed', (e) =>
      if e.newTrace? then @useTrace(e.newTrace) else @noTrace()
    if Stacktrace.getActivated? then @hide()

  beforeRemove: ->
    @unsubscribe Stacktrace

  useTrace: (trace) ->
    @removeClass 'inactive'
    @message.text(trace.message)
    @show()

  deactivateTrace: ->
    Stacktrace.getActivated().deactivate()

  noTrace: ->
    @addClass 'inactive'
    @message.text('')
    @hide()

  backToTrace: ->
    url = Stacktrace.getActivated()?.getUrl()
    atom.workspace.open(url) if url

module.exports = NavigationView: NavigationView

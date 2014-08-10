{View} = require 'atom'
{Subscriber} = require 'emissary'
{Stacktrace} = require './stacktrace'

class NavigationView extends View

  Subscriber.includeInto this

  @content: ->
    activatedClass = if Stacktrace.getActivated()? then '' else 'inactive'

    @div class: "tool-panel panel-bottom padded stacktrace navigation #{activatedClass}", =>
      @h2 class: 'text-highlight message', outlet: 'message', click: 'backToTrace'

  initialize: ->
    @subscribe Stacktrace, 'active-changed', (e) =>
      if e.newTrace? then @useTrace(e.newTrace) else @noTrace()

  beforeRemove: ->
    @unsubscribe Stacktrace

  useTrace: (trace) ->
    @removeClass 'inactive'
    @message.text(trace.message)

  noTrace: ->
    @addClass 'inactive'
    @message.text('')

  backToTrace: ->
    url = Stacktrace.getActivated()?.getUrl()
    atom.workspace.open(url) if url

module.exports = NavigationView: NavigationView

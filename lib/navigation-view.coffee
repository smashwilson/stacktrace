{View} = require 'atom'
{Subscriber} = require 'emissary'
{Stacktrace} = require './stacktrace'

class NavigationView extends View

  Subscriber.includeInto this

  @content: ->
    activatedClass = if Stacktrace.getActivated()? then '' else 'inactive'

    @div class: "tool-panel panel-bottom padded stacktrace navigation #{activatedClass}"

  initialize: ->
    @subscribe Stacktrace, 'active-changed', (e) =>
      if e.newTrace? then @removeClass 'inactive' else @addClass 'inactive'

  beforeRemove: ->
    @unsubscribe Stacktrace

module.exports = NavigationView: NavigationView

{View} = require 'atom'
{Stacktrace} = require './stacktrace'

class NavigationView extends View

  @content: ->
    @div class: 'tool-panel panel-bottom padded stacktrace navigation'

module.exports = NavigationView: NavigationView

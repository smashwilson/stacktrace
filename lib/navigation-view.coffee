{View} = require 'atom'

class NavigationView extends View

  @content: ->
    @div class: 'tool-panel panel-bottom padded stacktrace navigation'

module.exports = NavigationView: NavigationView

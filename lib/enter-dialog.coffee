{View, EditorView} = require 'atom'

class EnterDialog extends View

  @content: ->
    @div class: 'stacktrace enter-dialog overlay from-top', =>
      @subview 'traceEditor', new EditorView(mini: true)
      @button({
        class: 'btn btn-lg btn-primary inline-block',
        click: 'accept'
      }, 'Accept')

  accept: ->
    atom.emit 'stacktrace:accept-trace', trace: @traceEditor.getText()

module.exports = EnterDialog

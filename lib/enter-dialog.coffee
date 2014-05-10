{View, EditorView} = require 'atom'

class EnterDialog extends View

  @content: ->
    @div class: 'stacktrace enter-dialog overlay from-top', =>
      @h2 class: 'text-info block', 'Paste a stacktrace here:'
      @div class: 'block', =>
        @subview 'traceEditor', new EditorView(mini: true)
      @div class: 'block padded', =>
        @button({
          class: 'btn btn-lg btn-primary inline-block',
          click: 'traceIt'
        }, 'Trace It!')
        @button({
          class: 'btn btn-lg inline-block',
          click: 'cancel'
        }, 'Cancel')

  initialize: ->
    @traceEditor.focus()

  traceIt: ->
    atom.emit 'stacktrace:accept-trace', trace: @traceEditor.getText()
    @remove()

  cancel: -> @remove()

module.exports = EnterDialog

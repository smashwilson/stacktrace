{CompositeDisposable} = require 'event-kit'
{View, TextEditorView} = require 'atom-space-pen-views'

class EnterDialog extends View

  @content: ->
    @div class: 'stacktrace enter-dialog overlay from-top', =>
      @h2 class: 'text-info block', 'Paste a stacktrace here:'
      @div class: 'block', =>
        @subview 'traceEditor', new TextEditorView(mini: true)
      @div class: 'block padded', =>
        @button({
          class: 'btn btn-lg btn-primary inline-block',
          click: 'traceIt'
        }, 'Trace It!')
        @button({
          class: 'btn btn-lg inline-block',
          click: 'cancel'
        }, 'Cancel')

  initialize: (@pkg) ->
    @subs = new CompositeDisposable()

    @traceEditor.focus()

    @subs.add atom.commands.add '.stacktrace.enter-dialog', 'core:cancel', => @cancel()

  traceIt: ->
    @pkg.traceHandlerV1().acceptTrace @traceEditor.getText()
    @remove()

  cancel: -> @remove()

module.exports = EnterDialog

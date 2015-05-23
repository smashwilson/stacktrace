# Decorate any lines within an {Editor} that correspond to an active {Stacktrace}.

{Stacktrace} = require './stacktrace'

markers = []

module.exports =
  decorate: (editor) ->
    active = Stacktrace.getActivated()
    return unless active?

    for frame in active.frames
      if frame.realPath is editor.getPath()
        range = editor.getBuffer().rangeForRow frame.bufferLineNumber()
        marker = editor.markBufferRange range, persistent: false
        editor.decorateMarker marker, type: 'line', class: 'line-stackframe'
        editor.decorateMarker marker, type: 'line-number', class: 'line-number-stackframe'
        markers.push marker

  cleanup: ->
    m.destroy() for m in markers

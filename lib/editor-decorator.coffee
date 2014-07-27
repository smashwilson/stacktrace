# Decorate any lines within an {Editor} that correspond to an active {Stacktrace}.

{Stacktrace} = require './stacktrace'

markers = []

module.exports = (editor) ->
  m.destroy() for m in markers
  markers = []

  active = Stacktrace.getActivated()
  return unless active?

  for frame in active.frames
    if frame.realPath is editor.getPath()
      range = editor.getBuffer().rangeForRow frame.bufferLineNumber()
      marker = editor.markBufferRange range
      editor.decorateMarker marker, type: 'line', class: 'line-stackframe'
      editor.decorateMarker marker, type: 'gutter', class: 'gutter-stackframe'
      markers.push marker

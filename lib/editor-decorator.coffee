# Decorate any lines within an {Editor} that correspond to an active {Stacktrace}.

{Stacktrace} = require './stacktrace'

module.exports = (editor) ->
  active = Stacktrace.getActivated()
  return unless active?

  for frame in active.frames
    if frame.realPath is editor.getPath()
      range = editor.getBuffer().rangeForRow frame.bufferLineNumber()
      marker = editor.markBufferRange range
      console.log "Decorating #{editor.getPath()} range #{range}"
      editor.decorateMarker marker, type: 'line', class: 'line-stackframe'

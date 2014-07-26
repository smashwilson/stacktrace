
module.exports =

  recognize: (line, f, {emitMessage, emitFrame, emitStack}) ->
    m = line.match /// ^
      (.*Error) : # Error name
      (.+) # Message
      $
    ///
    return unless m?

    emitMessage line

  consume: (line, f, {emitMessage, emitFrame, emitStack}) ->
    m = line.match /// ^
      at \s+
      ([^(]+)   # Function name
      \(
        ([^:]+) : # Path
        (\d+)   : # Line
        (\d+)     # Column
      \)
    ///
    return emitStack() unless m?

    f.functionName m[1].trim()
    f.path m[2]
    f.lineNumber parseInt m[3]
    emitFrame()

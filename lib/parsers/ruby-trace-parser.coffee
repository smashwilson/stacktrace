
module.exports =

  recognize: (line, f, {emitMessage, emitFrame, emitStack}) ->
    m = line.match /// ^
      ([^:]+) :  # File path
      (\d+) :    # Line number
      in \s* ` ([^']+) ' # Function name
      : \s (.+) # Error message
      $
    ///
    return unless m?

    f.path m[1]
    f.lineNumber parseInt m[2]
    f.functionName m[3]

    emitMessage m[4]
    emitFrame()

  consume: (line, f, {emitMessage, emitFrame, emitStack}) ->
    m = line.match /// ^
      from \s+   # from
      ([^:]+) :  # File path
      (\d+) :    # Line number
      in \s* ` ([^']+) ' # Function name
      $
    ///
    return emitStack() unless m?

    f.path m[1]
    f.lineNumber parseInt m[2]
    f.functionName m[3]
    emitFrame()

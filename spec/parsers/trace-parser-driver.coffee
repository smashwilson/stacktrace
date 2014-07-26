
module.exports =

  # Public: Imitate sending a chunk of text to the chosen parser.
  #
  drive: (parser, text) ->
    lines = (line.trim() for line in text.split(/\r?\n/))

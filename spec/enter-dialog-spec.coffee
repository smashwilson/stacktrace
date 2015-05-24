EnterDialog = require '../lib/enter-dialog'

TRACE = """
  /home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)
	  from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'
	  from entry.rb:7:in `toplevel'
	  from entry.rb:10:in `<main>'
    """

describe 'EnterDialog', ->

  it 'calls an acceptTrace function', ->
    txt = null
    pkg = traceHandlerV1: ->
      acceptTrace: (t) -> txt = t

    d = new EnterDialog(pkg)
    d.traceEditor.setText(TRACE)
    d.traceIt()

    expect(txt).toEqual TRACE

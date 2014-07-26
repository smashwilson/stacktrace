{StacktraceView, FrameView} = require '../lib/stacktrace-view'
{Stacktrace, Frame} = require '../lib/stacktrace'

frames = [
  new Frame('raw0', 'bottom.rb', 12, 'botfunc', 'Boom')
  new Frame('raw1', 'middle.rb', 42, 'midfunc')
  new Frame('raw2', 'top.rb', 37, 'topfunc')
]
trace = new Stacktrace(frames, 'Boom')

describe 'StacktraceView', ->
  [view] = []

  beforeEach ->
    view = new StacktraceView(trace)

  afterEach ->
    Stacktrace.clearRegistry()

  it 'registers an opener', ->
    opener = null
    mock =
      registerOpener: (callback) -> opener = callback
    StacktraceView.registerIn(mock)

    expect(opener).not.toBeNull()
    expect(opener '/some/other/path').toBeUndefined()

    trace.register()
    expect(opener(trace.getUrl()).trace).toBe(trace)

  it 'shows the error message', ->
    text = view.find('.error-message').text()
    expect(text).toEqual('Boom')

  it 'renders a subview for each frame'

describe 'FrameView', ->
  [view] = []

  beforeEach ->
    view = new FrameView(frames[1])

  it 'shows the filename'
  it 'shows the line number'
  it 'shows the function name'

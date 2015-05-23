{StacktraceView, FrameView} = require '../lib/stacktrace-view'
{Stacktrace, Frame} = require '../lib/stacktrace'

frames = [
  new Frame('raw0', 'bottom.rb', 12, 'botfunc')
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
      addOpener: (callback) -> opener = callback
    StacktraceView.registerIn(mock)

    expect(opener).not.toBeNull()
    expect(opener '/some/other/path').toBeUndefined()

    trace.register()
    stv = opener(trace.getUrl())
    expect(stv.trace).toBe(trace)
    expect(opener(trace.getUrl())).toBe(stv)

  it 'shows the error message', ->
    text = view.find('.error-message').text()
    expect(text).toEqual('Boom')

  it 'renders a subview for each frame', ->
    vs = view.find('.frame')
    expect(vs.length).toBe(3)

  it 'changes its class when its trace is activated or deactivated', ->
    Stacktrace.getActivated()?.deactivate()
    expect(view.hasClass 'activated').toBe(false)
    trace.activate()
    expect(view.hasClass 'activated').toBe(true)

describe 'FrameView', ->
  [view] = []

  beforeEach ->
    view = new FrameView frames[1], ->

  it 'shows the filename and line number', ->
    text = view.find('.source-location').text()
    expect(text).toMatch(/middle\.rb/)
    expect(text).toMatch(/42/)

  it 'shows the function name', ->
    text = view.find('.function-name').text()
    expect(text).toEqual('midfunc')

{WorkspaceView} = require 'atom'
{Stacktrace, Frame} = require '../lib/stacktrace'
{NavigationView} = require '../lib/navigation-view'

frames = [
  new Frame('raw0', 'bottom.rb', 12, 'botfunc')
  new Frame('raw1', 'middle.rb', 42, 'midfunc')
  new Frame('raw2', 'top.rb', 37, 'topfunc')
]
trace = new Stacktrace(frames, 'Boom')

describe 'NavigationView', ->
  [view] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    activationPromise = atom.packages.activatePackage('stacktrace')

    atom.workspaceView.trigger 'stacktrace:paste'

    waitsForPromise -> activationPromise

    runs ->
      view = atom.workspaceView.find('.stacktrace.navigation').view()

  afterEach ->
    Stacktrace.getActivated()?.deactivate()

  it 'attaches itself to the workspace', ->
    expect(view).not.toBeNull()

  describe 'with an active stacktrace', ->
    [view] = []

    beforeEach ->
      trace.activate()
      view = atom.workspaceView.find('.stacktrace.navigation').view()

    it 'should be visible', ->
      expect(view.hasClass 'active').toBeTruthy()

    it 'shows the active trace name', ->
      text = view.find('.message').text()
      expect(text).toEqual('Boom')

    it 'navigates back to the trace on a click', ->
      view.backToTrace()
      expect(atom.workspaceView.getActiveView().hasClass '.stacktrace.traceview').toBeTruthy()

    it 'deactivates the trace', ->
      view.deactivateTrace()
      expect(trace.isActive()).toBeFalsy()

    describe 'on an editor corresponding to a single frame', ->

      it 'shows the frame index'

      it 'navigates to the next frame'

      it 'navigates to the previous frame'

    describe 'on an editor with multiple frames', ->

      it 'notices if you manually navigate to a different frame'

    describe 'on an editor not corresponding to a frame', ->

      it 'navigates back to the last active frame'

  describe 'without an active stacktrace', ->

    it 'hides itself'

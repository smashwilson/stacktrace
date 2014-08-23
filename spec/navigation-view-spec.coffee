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
    Stacktrace.clearRegistry()

  it 'attaches itself to the workspace', ->
    expect(view).not.toBeNull()

  describe 'with an active stacktrace', ->

    beforeEach ->
      trace.register()
      trace.activate()

    it 'should be visible', ->
      expect(view.hasClass 'inactive').toBeFalsy()

    it 'shows the active trace name', ->
      text = view.find('.message').text()
      expect(text).toEqual('Boom')

    it 'navigates back to the trace on a click', ->
      waitsForPromise -> view.backToTrace()

      runs ->
        expect(atom.workspaceView.getActiveView().hasClass 'traceview').toBeTruthy()

    it 'deactivates the trace', ->
      view.deactivateTrace()
      expect(trace.isActive()).toBeFalsy()

    describe 'on an editor corresponding to a single frame', ->
      [editor] = []

      beforeEach ->
        waitsForPromise -> trace.frames[1].navigateTo()

        runs ->
          editor = atom.workspace.getActiveEditor()

      it 'shows the current frame and its index', ->
        expect(view.find('.current-frame.function').text()).toBe('midfunc')
        expect(view.find('.current-frame.index').text()).toBe('2')
        expect(view.find('.current-frame.total').text()).toBe('3')

      it 'navigates to the next frame'

      it 'navigates to the previous frame'

    describe 'on an editor with multiple frames', ->

      it 'notices if you manually navigate to a different frame'

    describe 'on an editor not corresponding to a frame', ->

      it 'navigates back to the last active frame'

  describe 'without an active stacktrace', ->

    it 'hides itself'

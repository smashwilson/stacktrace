{$} = require 'atom-space-pen-views'
{Stacktrace, Frame} = require '../lib/stacktrace'
{NavigationView} = require '../lib/navigation-view'

path = require 'path'

fixturePath = (p) ->
  path.join __dirname, 'fixtures', p

frames = [
  new Frame('raw0', fixturePath('bottom.rb'), 12, 'botfunc')
  new Frame('raw1', fixturePath('middle.rb'), 42, 'midfunc')
  new Frame('raw2', fixturePath('top.rb'), 37, 'topfunc')
  new Frame('raw3', fixturePath('middle.rb'), 5, 'otherfunc')
]
trace = new Stacktrace(frames, 'Boom')

describe 'NavigationView', ->
  [view] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('stacktrace')

    jasmine.attachToDOM(workspaceElement)

    atom.commands.dispatch workspaceElement, 'stacktrace:paste'

    waitsForPromise -> activationPromise

    runs ->
      panels = atom.workspace.getBottomPanels()
      for panel in panels
        view = panel.item if panel.item.hasClass 'navigation'

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
        expect(atom.workspace.getActivePaneItem().hasClass 'traceview').toBeTruthy()

    it 'deactivates the trace', ->
      view.deactivateTrace()
      expect(trace.isActive()).toBeFalsy()

    describe 'on an editor corresponding to a single frame', ->
      [editor] = []

      beforeEach ->
        waitsForPromise -> trace.frames[2].navigateTo()

        runs ->
          editor = atom.workspace.getActiveTextEditor()

      it 'shows the current frame and its index', ->
        expect(view.find('.current-frame .function').text()).toBe('topfunc')
        expect(view.find('.current-frame .index').text()).toBe('3')
        expect(view.find('.current-frame .total').text()).toBe('4')

      it "navigates to the caller's frame", ->
        waitsForPromise -> view.navigateToCaller()

        runs ->
          expect(view.frame).toBe(trace.frames[3])

      it 'navigates to the called frame', ->
        waitsForPromise -> view.navigateToCalled()

        runs ->
          expect(view.frame).toBe(trace.frames[1])

      it 'navigates back to the last active frame', ->
        editor.setCursorBufferPosition [5, 0]
        expect(view.find '.current-frame.unfocused').toHaveLength 1

        waitsForPromise -> view.navigateToLastActive()

        runs ->
          expect(view.find '.current-frame.unfocused').toHaveLength 0
          expect(editor.getCursorBufferPosition().row).toBe 36

    describe 'on an editor with multiple frames', ->
      [editor] = []

      beforeEach ->
        waitsForPromise -> trace.frames[1].navigateTo()

        runs ->
          editor = atom.workspace.getActiveTextEditor()

      it 'notices if you manually navigate to a different frame', ->
        expect(view.find('.current-frame .function').text()).toEqual 'midfunc'

        editor.setCursorBufferPosition [4, 1]

        expect(view.frame).toBe(trace.frames[3])
        expect(view.find('.current-frame .function').text()).toEqual 'otherfunc'

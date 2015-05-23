path = require 'path'

{$} = require 'atom-space-pen-views'
{Stacktrace, Frame} = require '../lib/stacktrace'
{decorate, cleanup} = require '../lib/editor-decorator'

framePath = (fname) -> path.join __dirname, 'fixtures', fname

frames = [
  new Frame('raw0', framePath('bottom.rb'), 12, 'botfunc')
  new Frame('raw1', framePath('middle.rb'), 42, 'midfunc')
  new Frame('raw2', framePath('top.rb'), 37, 'topfunc')
  new Frame('raw3', framePath('middle.rb'), 5, 'otherfunc')
]
trace = new Stacktrace(frames, 'Boom')

describe 'editorDecorator', ->
  [editor, editorView] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('stacktrace')

    jasmine.attachToDOM(workspaceElement)

  afterEach ->
    Stacktrace.getActivated()?.deactivate()

  withEditorOn = (fname, callback) ->
    waitsForPromise ->
      atom.workspace.open(framePath fname)

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      callback()

  linesMatching = (selector) -> $(editorView.shadowRoot).find selector

  it 'does nothing if there is no active trace', ->
    expect(Stacktrace.getActivated()).toBeNull()

    withEditorOn 'bottom.rb', ->
      decorate(editor)
      expect(linesMatching '.line.line-stackframe').toHaveLength 0

  describe 'with an active trace', ->

    beforeEach -> trace.activate()

    it "does nothing if the file doesn't appear in the active trace", ->
      withEditorOn 'context.txt', ->
        decorate(editor)
        expect(linesMatching '.line.line-stackframe').toHaveLength 0

    it 'decorates stackframe lines in applicable editors', ->
      withEditorOn 'bottom.rb', ->
        decorate(editor)
        decorated = linesMatching '.line.line-stackframe'
        expect(decorated).toHaveLength 1
        expect(decorated.text()).toEqual("  puts 'this is the stack line'")

    it 'removes prior decorations when deactivated', ->
      withEditorOn 'bottom.rb', ->
        decorate(editor)
        trace.deactivate()
        cleanup()
        expect($(editorView).find '.line.line-stackframe').toHaveLength 0

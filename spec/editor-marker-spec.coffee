path = require 'path'
{Editor, WorkspaceView} = require 'atom'

{Stacktrace, Frame} = require '../lib/stacktrace'
editorDecorator = require '../lib/editor-decorator'

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
    atom.workspaceView = new WorkspaceView

  afterEach ->
    Stacktrace.getActivated()?.deactivate()

  withEditorOn = (fname, callback) ->
    waitsForPromise ->
      atom.workspace.open(framePath fname)

    runs ->
      atom.workspaceView.attachToDom()
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()
      callback()

  it 'does nothing if there is no active trace', ->
    expect(Stacktrace.getActivated()).toBeNull()

    withEditorOn 'bottom.rb', ->
      editorDecorator(editor)
      expect(editorView.find '.line.line-stackframe').toHaveLength 0

  describe 'with an active trace', ->

    beforeEach -> trace.activate()

    it "does nothing if the file doesn't appear in the active trace", ->
      withEditorOn 'context.txt', ->
        editorDecorator(editor)
        expect(editorView.find '.line.line-stackframe').toHaveLength 0

    it 'decorates stackframe lines in applicable editors', ->
      withEditorOn 'bottom.rb', ->
        editorDecorator(editor)
        decorated = editorView.find '.line.line-stackframe'
        expect(decorated).toHaveLength 1
        expect(decorated.text()).toEqual("  puts 'this is the stack line'")

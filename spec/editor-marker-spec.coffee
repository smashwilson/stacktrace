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

describe 'editorMarker', ->
  [editor, editorView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

  withEditorOn = (fname, callback) ->
    waitsForPromise ->
      atom.workspace.open(framePath fname)

    runs ->
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()
      callback()

  it 'does nothing if there is no active trace', ->
    expect(Stacktrace.getActivated()).toBeNull()

    withEditorOn 'bottom.rb', ->
      editorDecorator(editor)
      expect(editorView.find '.line.line-stackframe').toHaveLength 0

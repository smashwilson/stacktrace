path = require 'path'

{WorkspaceView} = require 'atom'
Stacktrace = require '../lib/main'

describe "Main", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('stacktrace')

  describe 'when the stacktrace:paste event is triggered', ->

    beforeEach ->
      atom.workspaceView.trigger 'stacktrace:paste'
      waitsForPromise -> activationPromise

    it 'activates the package', ->
      expect(atom.packages.isPackageActive 'stacktrace').toBe(true)

    it 'displays the EnterDialog', ->
      expect(atom.workspaceView.find '.enter-dialog').toExist()

  describe 'when the stacktrace:from-selection event is triggered', ->

    beforeEach ->
      path = path.join __dirname, 'fixtures', 'withtrace.txt'
      editorPromise = atom.workspace.open(path)

      waitsForPromise -> editorPromise

      runs ->
        editorPromise.then (editor) ->
          editor.setSelectedBufferRange [[1, 0], [7, 0]]
        atom.workspaceView.trigger 'stacktrace:from-selection'

      waitsForPromise -> activationPromise

    it 'activates the package', ->
      expect(atom.packages.isPackageActive 'stacktrace').toBe(true)

    it 'displays a StacktraceView', ->
      expect(atom.workspaceView.find '.traceview').toExist()

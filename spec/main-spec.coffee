path = require 'path'

{$} = require 'atom-space-pen-views'
Stacktrace = require '../lib/main'

describe "Main", ->
  activationPromise = null
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('stacktrace')

    jasmine.attachToDOM(workspaceElement)

  describe 'when the stacktrace:paste event is triggered', ->

    beforeEach ->
      atom.commands.dispatch workspaceElement, 'stacktrace:paste'
      waitsForPromise -> activationPromise

    it 'activates the package', ->
      expect(atom.packages.isPackageActive 'stacktrace').toBe(true)

    it 'displays the EnterDialog', ->
      expect($(workspaceElement).find '.enter-dialog').toExist()

  describe 'when the stacktrace:from-selection event is triggered', ->

    beforeEach ->
      p = path.join __dirname, 'fixtures', 'withtrace.txt'
      editorPromise = atom.workspace.open(p)

      waitsForPromise -> editorPromise

      runs ->
        editorPromise.then (editor) ->
          editor.setSelectedBufferRange [[1, 0], [7, 0]]
          atom.commands.dispatch workspaceElement, 'stacktrace:from-selection'

      waitsForPromise -> activationPromise

    it 'activates the package', ->
      expect(atom.packages.isPackageActive 'stacktrace').toBe(true)

    it 'displays a StacktraceView', ->
      expect($(workspaceElement).find '.traceview').toExist()

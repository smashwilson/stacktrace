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

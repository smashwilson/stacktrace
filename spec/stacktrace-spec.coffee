{WorkspaceView} = require 'atom'
Stacktrace = require '../lib/stacktrace'

describe "Stacktrace", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('stacktrace')

  describe "when the stacktrace:enter event is triggered", ->
    it 'activates the package'
    it 'displays the EnterDialog'

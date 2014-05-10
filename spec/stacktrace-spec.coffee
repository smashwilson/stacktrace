{WorkspaceView} = require 'atom'
Stacktrace = require '../lib/stacktrace'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Stacktrace", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('stacktrace')

  describe "when the stacktrace:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.stacktrace')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'stacktrace:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.stacktrace')).toExist()
        atom.workspaceView.trigger 'stacktrace:toggle'
        expect(atom.workspaceView.find('.stacktrace')).not.toExist()

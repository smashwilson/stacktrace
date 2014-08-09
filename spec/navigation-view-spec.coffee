{WorkspaceView} = require 'atom'
{Stacktrace, Frame} = require '../lib/stacktrace'
{NavigationView} = require '../lib/navigation-view'

describe 'NavigationView', ->

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    activationPromise = atom.packages.activatePackage('stacktrace')

    atom.workspaceView.trigger 'stacktrace:paste'

    waitsForPromise -> activationPromise

  it 'attaches itself to the workspace', ->
    expect(atom.workspaceView.find '.stacktrace.navigation').toHaveLength 1

  describe 'with an active stacktrace', ->

    it 'shows the active trace name'

    it 'navigates back to the trace on a click'

    it 'deactivates the trace'

    describe 'on an editor corresponding to a single frame', ->

      it 'shows the frame index'

      it 'navigates to the next frame'

      it 'navigates to the previous frame'

    describe 'on an editor with multiple frames', ->

      it 'notices if you manually navigate to a different frame'

    describe 'on an editor not corresponding to a frame', ->

      it 'navigates back to the last active frame'

  describe 'without an active stacktrace', ->

    it 'hides itself'

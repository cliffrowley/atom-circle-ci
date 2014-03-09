CircleCiStatusView = require './circle-ci-status-view'

module.exports =

circleCiStatusView: null

activate: (state) ->
  atom.config.setDefaults 'circle-ci', apiToken: ''

  if atom.workspaceView.statusBar?
    @showStatus()
  else
    atom.packages.once 'activated', =>
      @showStatus()

deactivate: ->
  @hideStatus()

showStatus: ->
  @circleCiStatusView ?= new CircleCiStatusView

hideStatus: ->
  @circleCiStatusView.destroy()
  @circleCiStatusView = null

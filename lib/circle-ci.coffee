CircleCiStatusView = require './circle-ci-status-view'

module.exports =
  view: null

  activate: ->
    atom.config.setDefaults 'circle-ci', apiToken: '', pollFrequency: 10, iconColor: false

    atom.packages.onDidActivateInitialPackages =>
      statusBar = document.querySelector('status-bar')
      if statusBar?
        @view ?= new CircleCiStatusView

  deactivate: ->
    @view.destroy()
    @view = null

{View}        = require 'atom'
CircleWatcher = require './circle-watcher'
alert         = require './alert'

module.exports =

class CircleCiStatusView extends View
  @content: ->
    @div class: 'circle-ci-status-view inline-block', =>
      @span outlet: 'statusIcon'
      @span outlet: 'statusLabel'

  initialize: ->
    apiToken = atom.config.get 'circle-ci.apiToken'
    return unless apiToken?

    @watcher = new CircleWatcher apiToken
    @watcher.on 'updated', (data) =>
      @showBuildStatus data[0]
    @watcher.on 'failed', (data, response) =>
      message = if response?.statusCode is 401
        'Token is invalid, check your settings!'
      else
        response?.message or response or data
      @showError message

    @watcher.start()

  destroy: ->
    @watcher.stop()
    @detach()

  showBuildStatus: (build) ->
    @setStatusIcon build.status
    @statusLabel.text "#{build.build_num} (#{build.branch})"

  showError: (message) ->
    @setStatusIcon 'error'
    @statusLabel.text ''
    alert.show "Circle CI Error: #{message}"

  setStatusIcon: (type) ->
    icon = switch type
      when 'running'  then 'icon-sync'
      when 'success'  then 'icon-check'
      when 'failed'   then 'icon-alert'
      when 'canceled' then 'icon-x'
      else                 'icon-slash'
    @statusIcon.removeClass().addClass "icon #{icon}"
    atom.workspaceView.statusBar.appendRight(this)

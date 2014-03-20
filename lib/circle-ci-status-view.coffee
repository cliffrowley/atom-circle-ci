{$$, View} = require 'atom'

CircleCiClient = require './circle-ci-client'

module.exports =
  class CircleCiStatusView extends View
    @content: ->
      @div class: 'circle-ci-status-view inline-block', =>
        @span outlet: 'statusIcon'
        @span outlet: 'statusLabel'

    initialize: ->
      @repo          = atom.project.getRepo()
      @apiToken      = atom.config.get 'circle-ci.apiToken'
      @pollFrequency = atom.config.get 'circle-ci.pollFrequency'
      @login() if @repo and @apiToken?

    login: ->
      @api = new CircleCiClient @apiToken
      @api.login (user) =>
        @fetchBuildArray() if user?

    fetchBuildArray: ->
      url = @repo.getOriginUrl()
      return unless url?
      # match = url.match /.*github\.com:(.*)\/(.*)\.git/
      match = url.match /.*github\.com\/(.*)\/(.*)\.git/
      [_, @username, @projectname] = match if match?
      return unless @username? && @projectname?
      @api.lastBuild @username, @projectname, (buildArray) =>
        @parseBuildArray buildArray if buildArray?
        window.setTimeout =>
          @fetchBuildArray()
        , @pollFrequency * 1000

    parseBuildArray: (buildArray) ->
      build = buildArray[0] unless buildArray.length is 0
      return unless build?
      @showStatus build.status
      @statusLabel.text "#{build.build_num} (#{build.branch})"

    destroy: ->
      @detach()

    notify: (message) ->
      view = $$ ->
        @div tabIndex: -1, class: 'overlay from-top', =>
          @span class: 'inline-block'
          @span "Circle CI: #{message}"

      atom.workspaceView.append view

      setTimeout ->
        view.detach()
      , 5000

    showStatus: (status) ->
      icon = switch status
        when 'running'  then 'icon-sync'
        when 'success'  then 'icon-check'
        when 'failed'   then 'icon-alert'
        when 'canceled' then 'icon-x'
        else                 'icon-slash'

      @statusIcon.removeClass().addClass "icon #{icon}"

      atom.workspaceView.statusBar.appendRight(this)

    hideStatus: ->
      @detach()

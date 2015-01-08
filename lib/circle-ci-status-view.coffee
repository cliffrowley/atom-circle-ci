{$$, View} = require 'atom'

CircleCiClient = require './circle-ci-client'

module.exports =
  class CircleCiStatusView extends View
    @content: ->
      @div class: 'circle-ci-status-view inline-block', =>
        @span outlet: 'statusIcon'
        @a outlet: 'statusLabel'

    initialize: ->
      @repo          = atom.project.getRepo()
      @apiToken      = atom.config.get 'circle-ci.apiToken'
      @pollFrequency = atom.config.get 'circle-ci.pollFrequency'
      @login() if @repo and @apiToken?

    login: ->
      @api = new CircleCiClient @apiToken
      @api.login (user) =>
        if user?
          @fetchBuildArray()
        else
          @showStatus 'error'
          @statusLabel.text "(unable to log in to circle ci)"

    fetchBuildArray: ->
      url = @repo.getOriginUrl()
      return unless url?
      match = url.match /.*github\.com(?::|\/)(.*)\/(.*)\.git/
      [_, username, projectname] = match if match?
      return unless username? && projectname?

      # The head will either be a branch name like 'master' or a hash.
      head = @repo.getShortHead()
      if @repo.hasBranch head
        @api.lastBuild username, projectname, head, (data) =>
          @parseBuildArray data
          window.setTimeout =>
            @fetchBuildArray()
          , @pollFrequency * 1000
      else
        @showStatus 'detached'
        @statusLabel.text "(detached HEAD)"

    parseBuildArray: (buildArray) ->
      if buildArray?
        if buildArray.length > 0
          build = buildArray[0]
          @showStatus build.status
          @statusLabel.text "#{build.build_num} (#{build.branch})"
          @statusLabel.attr("href", "#{build.build_url}")
        else
          @showStatus 'none'
          @statusLabel.text "(no build status available)"
      else
        @showStatus 'error'
        @statusLabel.text "(circle ci error)"

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
        when 'fixed'    then 'icon-check'
        when 'failed'   then 'icon-alert'
        when 'canceled' then 'icon-x'
        when 'no_tests' then 'icon-circle-slash'
        else                 'icon-circle-slash'

      @statusIcon.removeClass().addClass "icon #{icon}"

      atom.workspaceView.statusBar.appendRight(this)

    hideStatus: ->
      @detach()

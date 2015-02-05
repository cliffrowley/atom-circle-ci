{View, $$} = require 'atom-space-pen-views'

CircleCiClient = require './circle-ci-client'

module.exports =
  class CircleCiStatusView extends View
    @content: ->
      @div class: 'circle-ci-status-view inline-block', =>
        @span outlet: 'statusIcon'
        @a outlet: 'statusLabel'

    initialize: ->
      # @TODO atom wants us to stop using getRepo() and use getRepository, but
      # I can't find documentation! Link still says getRepo() -@framerate
      # https://atom.io/docs/api/v0.177.0/GitRepository
      @repo          = atom.project.getRepositories()[0]
      @apiToken      = atom.config.get 'circle-ci.apiToken'
      @pollFrequency = atom.config.get 'circle-ci.pollFrequency'

      return if not @repo or not @apiToken?

      atom.config.onDidChange 'circle-ci.iconColor', => @updateIconColor()

      @login()

    login: ->
      @api = new CircleCiClient @apiToken
      @api.login (user) =>
        if user?
          @fetchBuildArray()
        else
          @showStatus 'error'
          @statusLabel.text "(unable to log in to circle ci)"

    fetchBuildArray: ->
      url = @repo.getOriginURL()
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

    displayColorIcon: ->
      atom.config.get 'circle-ci.iconColor'

    updateIconColor: ->
      if @displayColorIcon() == true?
        @statusIcon.addClass("color")
      else
        @statusIcon.removeClass("color")

    showStatus: (status) ->
      icon = switch status
        when 'running'  then 'icon-sync'
        when 'success'  then 'icon-check'
        when 'fixed'    then 'icon-check'
        when 'failed'   then 'icon-alert'
        when 'canceled' then 'icon-x'
        when 'no_tests' then 'icon-circle-slash'
        else                 'icon-circle-slash'

      if @statusIcon
          @statusIcon.removeClass().addClass "icon #{icon}"
          @updateIconColor()

      statusBar = document.querySelector "status-bar"
      statusBar.addRightTile {item: this, priority: -1}

    hideStatus: ->
      @detach()

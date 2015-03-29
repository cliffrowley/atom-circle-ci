{View, $$} = require 'atom-space-pen-views'

CircleCiClient = require './circle-ci-client'

module.exports =
  class CircleCiStatusView extends View
    @content: ->
      @div class: 'circle-ci-status-view inline-block', =>
        @div outlet: 'statusWrapper', =>
          @span outlet: 'statusIcon'
          @a outlet: 'statusLabel'

    initialize: ->
      @repo          = atom.project.getRepositories()[0]
      @apiToken      = atom.config.get 'circle-ci.apiToken'
      @pollFrequency = atom.config.get 'circle-ci.pollFrequency'

      return if not @repo or not @apiToken?

      atom.config.onDidChange 'circle-ci.iconColor', => @updateIconColor()

      @login()

    login: ->
      @api = new CircleCiClient @apiToken
      @api.login (error, result) =>
        if !error && result.user?
          @fetchBuildArray()
        else
          if result.status == 'no-connection'
            @showStatus 'error', "No internet connection"
            @statusLabel.text "No network"

            window.setTimeout =>
              @login();
            , @pollFrequency * 1000
          else
            @showStatus 'error', "Unable to login to CircleCI"
            @statusLabel.text "Unauthorized"

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
          if data.status == 'no-connection'
            @showStatus 'error', "No internet connection"
            @statusLabel.text "No network"
            @statusLabel.removeAttr("href")
          else
            @parseBuildArray data.buildArray
      else
        @showStatus 'detached', "Detached from HEAD"
        @statusLabel.text "Detached"

      window.setTimeout =>
        @fetchBuildArray()
      , @pollFrequency * 1000

    parseBuildArray: (buildArray) ->
      if buildArray?
        if buildArray.length > 0
          build = buildArray[0]
          status = build.status?.replace('_', ' ').capitalize()
          build_time = build.build_time_millis / 1000

          @showStatus build.status, "#{status} by #{build.committer_name} in #{build_time} seconds"
          @statusLabel.text build.build_num
          @statusLabel.attr("href", "#{build.build_url}")
      else
        @showStatus 'error', "Unknown error when parsing API response"
        @statusLabel.text "Error"

    destroy: ->
      @detach()

    displayColorIcon: ->
      atom.config.get 'circle-ci.iconColor'

    updateIconColor: ->
      if @displayColorIcon() == true?
        @statusIcon.addClass("color")
      else
        @statusIcon.removeClass("color")

    showStatus: (status, tooltip="") ->
      icon = switch status
        when 'running'  then 'icon-sync'
        when 'success'  then 'icon-check'
        when 'fixed'    then 'icon-check'
        when 'failed'   then 'icon-alert'
        when 'canceled' then 'icon-x'
        when 'no_tests' then 'icon-circle-slash'
        else                 'icon-circle-slash'

      @tooltip.dispose() if @tooltip;
      if tooltip
        @tooltip = atom.tooltips.add @statusWrapper, title: tooltip

      @statusIcon.removeClass().addClass "icon #{icon}"
      @updateIconColor()

      statusBar = document.querySelector "status-bar"
      statusBar.addRightTile {item: this, priority: -1}

    hideStatus: ->
      @detach()

    String::capitalize = ->
      @substr(0, 1).toUpperCase() + @substr(1)

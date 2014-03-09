{EventEmitter} = require 'events'
CircleAPI      = require './circle-api'
repoUtils      = require './repo-utils'

module.exports =

# Internal: Periodically checks the build status for a Circle repo, emitting
# events in the process.
#
# Events:
#
# updating - Triggered prior to retrieving the latest build status from Circle.
# updated  - Triggered after retrieving the latest build status from Circle.
# failed   - Triggered if an error occurs while updating.
class CircleWatcher extends EventEmitter
  # Internal: Initialize a new instance.
  constructor: (@apiToken) ->
    @running = false

  # Internal: Start updating and emitting events.
  start: ->
    @running = true
    @update()

  # Internal: Stop updating and emitting events.
  stop: ->
    @running = false
    clearTimeout @timeout if @timeout?

  # Internal: Retrieve the latest build status from Circle CI.
  update: ->
    repo = atom.project?.getRepo?()
    name = repoUtils.shortName repo?.getOriginUrl?()
    api  = new CircleAPI @apiToken

    @emit 'updating'
    api.project name, {limit: 1}, (success, data, response) =>
      if success is true
        @emit 'updated', data, response
        @timeout = setTimeout =>
          @update()
        , 5000 if @running?
      else
        @stop()
        @emit 'failed', data, response

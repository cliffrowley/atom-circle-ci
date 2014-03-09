https = require 'https'

module.exports =

# Internal: Handles communication with Circle CI.
# See https://circleci.com/docs/api for more information.
class CircleAPI

  # Internal: Initialize a new instance with a Circle API token.
  constructor: (@apiToken) ->

  # Internal: Provides information about the signed in user.
  me: (callback) ->
    @_get 'me', {}, callback

  # Internal: List all of the projects the user is following on Circle CI, with
  #           build information ordered by branch.
  projects: (callback) ->
    @_get 'projects', {}, callback

  # Internal: Build summary for each of the last 30 builds for a single git
  #           repo.
  project: (repo, params, callback) ->
    @_get "project/#{repo}", params, callback

  # Internal: Send a GET request to the Circle CI API.
  _get: (path, params, callback) ->
    @_request 'GET', path, params, callback

  # Internal: Send a POST request to the Circle CI API.
  _post: (path, params, callback) ->
    @_request 'POST', path, params, callback

  # Internal: Send a request to the Circle CI API.
  _request: (method, path, params, callback) ->
    params or= {}
    params['circle-token'] = @apiToken

    query = ("#{k}=#{v}" for k,v of params).join '&'

    opts =
      method:   method.toUpperCase()
      hostname: 'circleci.com'
      path:     "/api/v1/#{path}?#{query}"
      headers:
        'Content-Type': 'application/json'
        'Accept':       'application/json'

    req = https.request opts, (res) =>
      data = ''

      res.on 'data', (chunk) =>
        data += chunk

      res.on 'end', =>
        json    = JSON.parse data
        success = res.statusCode is 200

        callback success, json, res

    req.on 'error', (error) =>
      callback false, error

    req.end()

RestClient = require('node-rest-client').Client

module.exports =
  class CircleCiClient
    baseURI: 'https://circleci.com/api/v1'

    methods:
      user:     'me'
      projects: 'projects'
      project:  'project/${username}/${projectname}'

    constructor: (@apiToken) ->
      @api = new RestClient
      for meth of @methods
        @api.registerMethod meth, "#{@baseURI}/#{@methods[meth]}", 'GET'

    invoke: (name, args, callback) ->
      args.parameters ?= {}
      args.headers    ?= {}
      args.parameters['circle-token'] = @apiToken
      args.headers['Accept'] = 'application/json'
      @api.methods[name](args, callback)

    login: (callback) ->
      @invoke 'user', {}, (data, response) =>
        switch response.statusCode
          when 200
            callback(data)
          when 401
            @log 'Circle CI: API token seems to be invalid', data, response
            callback(false)
          else
            @log 'Circle CI: returned unexpected status code', data, response
            callback(false)

    lastBuild: (username, projectname, callback) ->
      args =
        path:
          username:    username
          projectname: projectname
        parameters:
          limit: 1

      @invoke 'project', args, (data, response) =>
        switch response.statusCode
          when 200
            callback(data)
          else
            @log 'Circle CI: returned unexpected status code', data, response
            callback(false)

    log: (messages...) ->
      console.log message for message in messages

RestClient = require('node-rest-client').Client

module.exports =
  class CircleCiClient
    baseURI: 'https://circleci.com/api/v1'

    methods:
      user:     'me'
      projects: 'projects'
      project:  'project/${username}/${projectname}'
      branch:   'project/${username}/${projectname}/tree/${branchname}'

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
            callback data
          when 401
            @log 'Circle CI: API token seems to be invalid', data, response
            callback null
          else
            @log 'Circle CI: returned unexpected status code', data, response
            callback null

    lastBuild: (username, projectname, branchname, callback) ->
      args =
        path:
          username:    username
          projectname: projectname
          branchname:  branchname

      method = if branchname? then 'branch' else 'project'
      @invoke method, args, (data, response) =>
        switch response.statusCode
          when 200
            callback data
          else
            @log 'Circle CI: returned unexpected status code', data, response
            callback null

    log: (messages...) ->
      console.log message for message in messages

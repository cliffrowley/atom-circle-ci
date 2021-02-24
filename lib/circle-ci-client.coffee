RestClient = require('node-rest-client').Client

module.exports =
  class CircleCiClient
    baseURI: 'https://circleci.com/api/v1.1'

    methods:
      user:     'me'
      projects: 'projects'
      project:  'project/${vc_type}/${username}/${projectname}'
      branch:   'project/${vc_type}/${username}/${projectname}/tree/${branchname}'

    constructor: (@apiToken) ->
      @api = new RestClient
      for meth of @methods
        @api.registerMethod meth, "#{@baseURI}/#{@methods[meth]}", 'GET'

    invoke: (name, args, callback) ->
      args.parameters ?= {}
      args.headers    ?= {}
      args.parameters['circle-token'] = @apiToken
      args.headers['Accept'] = 'application/json'
      req = @api.methods[name](args, callback)
      req.on 'error', ( err ) ->
        callback null

    login: (callback) ->
      @invoke 'user', {}, (data, response) =>
        if !response
          callback true, { status: 'no-connection' }
        else
          switch response.statusCode
            when 200
              callback false, { status: 'ok', user: data }
            when 401
              @log 'Circle CI: API token seems to be invalid', data, response
              callback true, { status: 'invalid-token' }
            else
              @log 'Circle CI: returned unexpected status code', data, response
              callback true, { status: 'unknown-error' }

    lastBuild: (vc_type, username, projectname, branchname, callback) ->
      args =
        path:
          vc_type:     vc_type
          username:    username
          projectname: projectname
          branchname:  branchname
        parameters:
          limit: 1

      method = if branchname? then 'branch' else 'project'
      @invoke method, args, (data, response) =>
        if !response
          callback { status: 'no-connection' }
        else
          switch response.statusCode
            when 200
              callback { status: 'ok', buildArray: data }
            else
              @log 'Circle CI: returned unexpected status code', data, response
              callback { status: 'unknown-error' }

    log: (messages...) ->
      console.log message for message in messages

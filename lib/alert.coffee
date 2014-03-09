{$$} = require 'atom'

module.exports =

# Internal: Displays a simple alert view in the Atom workspace.
show: (message) ->
  view = $$ ->
    @div tabIndex: -1, class: 'overlay from-top', =>
      @span class: 'inline-block'
      @span message

  atom.workspaceView.append view
  view.focus()
  view.on 'blur', =>
    view.fadeOut 250, =>
      view.detach()

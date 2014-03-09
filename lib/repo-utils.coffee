module.exports =

# Internal: Returns the short name (e.g. owner/repo) for the specified origin.
# Currently only supports GitHub URLs, but could easily be enhanced to support
# others.
#
# repoURL - A string containing a Git repo URL.
shortName: (repoUrl) ->
  match = repoUrl.match /.*github\.com:(.*)\.git/
  match[1] if match?

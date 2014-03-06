# Circle CI

Shows the [Circle CI](http://circleci.com) build status for the current project in the Atom status bar.

![Circle CI](https://dl.dropboxusercontent.com/u/714833/Atom/packages/circle-ci/circle_ci.png)

## Configuring

Create an API token in your Circle CI [dashboard](https://circleci.com/account/api) and add it to the Circle CI package configuration in Atom's settings.

## Using

There's nothing to 'do' per se, just a few things you should be aware of.

1. When a project is opened, the repo URL is inspected to see if it is a GitHub project (which is the only SCM host currently supported by Circle CI).
2. If it is, the package will attempt to fetch the latest build status via the Circle CI API.
3. If successful, an icon representing the build status will be added to the status bar along with the build number and the branch that was last tested, and the package will check again in 10 seconds and repeat the process from step 2.
4. If any of the steps above are unsuccessful, the package will stop updating.

The icons are as follows:

| Icon                                             | Status   |
| ------------------------------------------------ | -------- |
| <span class="mega-octicon octicon-sync"></span>  | Running  |
| <span class="mega-octicon octicon-check"></span> | Success  |
| <span class="mega-octicon octicon-alert"></span> | Failure  |
| <span class="mega-octicon octicon-x"></span>     | Canceled |
| <span class="mega-octicon octicon-slash"></span> | Error    |

Please also see the limitations below.

## Limitations

Nothing is perfect, especially on its first outing - so here is a short list of limitations and known issues that you should probably be aware of.  I'll be use this package extensively myself, so you can be assured that I'll be reducing this list pretty quickly.

### Only the "origin" remote is supported

This will fit 90% of cases, but I'm aware that there will be times when it won't.  It's only this way because the [Atom Git API](https://atom.io/docs/api/v0.67.0/api/classes/Git.html) currently only supports fetching the origin URL.  Obviously it's not a massive effort to retrieve the list of remotes without using this API, but it didn't make it into this iteration.

### The latest build is not related to the current branch

Instead of showing the build status for the current branch, the status of the last build is displayed irrespective of the current branch.  It would obviously much more useful to display the status for the current branch, but I couldn't cram it in this iteration.  This is one of the first things on my todo list.

### Projects must already exist in Circle CI

Build status for a project is periodically refreshed (every 10 seconds currently), however if the project is not found in Circle CI when it is opened in Atom then it will not be checked again until the next time it's opened.  Therefore if you add the project to Circle CI after opening it in Atom, you will need to close and reopen it (or just reload the window).  It's likely I'll change this at some point, but it's a low priority task.

### Multiple accounts not supported

Currently you may only enter a single Circle CI token, which means you can only be logged into one account at a time.  This may or may not change, depending on whether there's a demand to support multiple accounts.  If you want this feature, please create an issue (or add a comment if an issue has already been created) or send me a pull request.

### The icons aren't terribly meaningful

I'm fully aware they're not very intuitive, but I just picked the closest I could find in the [Github icon set](https://github.com/styleguide/css/7.0) until I get a chance to replace them.

### Misc other things

There are other niggles I'm aware of, but please feel free to create issues on GitHub regardless.

## Contributing

Issues, sugestions and pull requests are more than welcome.

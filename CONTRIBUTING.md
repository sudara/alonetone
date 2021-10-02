## Setting up alonetone locally

### Requirements

Ruby 2.7.x

### MacOS

You will need to first install [Homebrew](https://brew.sh).

- `brew install libsndfile lame` (required for id3 tags and waveforms)
- `brew install vips` (required for processing images)
- `brew install yarn` (required for building assets)
- `brew install mysql` (required for local database)
  - before running rake to generate the data, you'll also need to start the mysql server, as well as have the root user with password 'root' and a currently logged in user with no password.
  - you can find currently logged in user by doing: `stat -f '%Su' /dev/console` will refer to this as currentUser
  - `mysql.server start`
  - `mysql -u root -h localhost` to open root mysql prompt.  In the prompt type the following lines, replacing currentUser with what you figured it out to be above
  - `SET PASSWORD FOR root@localhost='root';`
  - `CREATE USER 'currentUser'@'localhost' IDENTIFIED BY '';`
  - `GRANT ALL PRIVILEGES ON * . * TO 'currentUser'@'localhost';`

- Install gems
`bundle install`
- Install front-end dependencies
`yarn install --check-files`

- To create needed config, database, and load db/seeds*:
`rake setup`
- Create and seed database
`rake db:setup`
- `rails s`

*Note: alonetone uses 3 config files that are created by 'rake setup

> alonetone.yml (contains the application "secret" and app-specific settings)
>
> database.yml
>
> newrelic.yml (for performance tracking)

## Optional installs

The frontend code can take advantage of `MorphSVGPlugin` for more fluid SVG animations. If you have access to the plugin you can replace the stub file in `app/javascripts/animation/` to use the plugin.

## Logging in

After the bootstrap data is loaded, you can login using the test account. Username is "admin" and password is "testing123"

After login, click on the "Upload" button to upload your first mp3.

## Running alonetone

### Seeds

Instead of using a production dump or unique data locally, we use seed data that is generated programmatically. The code lives in `db/seeds.rb`.

To reset the seeds:

```
bundle exec rake db:reset
```

### Issues and workaround:

Seeing the following yarn error?
```
  Your Yarn packages are out of date!
  Please run `yarn install` to update.
```

Make sure you have the latest version of `npm` and `node`.
```
brew install yarn
yarn install
```

In the worst case `rm -rf node_modules` and `yarn install` again.

## Nomenclature and Historical Baggage That Can And Should Change

* The `Asset` model refers to an mp3
* `Track` is an entry in a `Playlist`
* Playlists are either albums or mixes, depending on what's inside them
* A user has one favorites playlist, which gets added to when you "heart" things
* The home page is `assets#latest`
* Too many views are in `shared/`

## Running specs

You can run guard, which will run the appropriate spec file after it or the file it's testing changes:

```
bundle exec guard start
```

### Feature specs and Percy

Feature specs are run in headless chrome. If you want to watch the browser be automated (to debug, etc) you can change the "driver" being used in `rails_helper.rb` from headless to normal chrome.

```
Capybara.default_driver = :selenium_chrome # :selenium_chrome_headless
```

Then you can run individual feature specs like so:

```
bundle exec rspec spec/features/home_page_spec.rb
```

This lets you do things like insert `sleep 20` to have the browser wait 20 seconds if you want to do things like inspect the browser state in tests.

Just remember not to commit sleep statements or the change to the non-headless chrome :)

## CSS Conventions

### General

CSS files are split into "components" which are either unique pages (e.g. playlist_edit), page types with shared behavior (e.g. static_pages) or actual components used across pages (e.g. blank_slate).

Selectors are kept as specific and local as possible, to reduce complex cascading dependencies which lead high cognitive overhead and unwanted interaction. Individual selectors are not meant to be reusable outside of their file's context and are often scoped by a specific top-level class for that reason (e.g. `.hero`). If identical styles need to be used for another page or something is being extracted into a common component, selectors should be extracted to a shared location and renamed appropriately.

Style location is also based on readability and maintainability (read: making sure files don't get too long and complex). For example, when creating new styles for a new page, a new css file is created and named after that page. When adding a playlist edit feature, styles are added to playlist edit.

All colors must be in variables due to themes.

### Themes

We have two themes, dark and white. Every piece of UI has to be made for both themes.

Each hex color value used across the site is defined by exactly one variable in `color_mapping.scss`, using a name derived from and synced with [the site's Figma file](https://www.figma.com/file/YdjrVsNumbBsWVo82Wje2h6N/alonetone-white-theme?node-id=0%3A1).

When a selector needs a color, a *new* unique variable name should be used for the color that describes where the color is being used, if it's for background/text, etc: `$view-all-background`

That variable should then be defined in *both* `white.scss` and `dark.scss`. Map that variable to the actual color name. Note that variables are grouped by the filename they are used in. Be sure to put your new variable in the right filename group.

## Pull Requests

We used to have this as a pull request template, but it got noisy and is less relevant once contributors become familiar with the project.

However, as a new contributor, we appreciate if the following is answered in the body of the pull request:

* For bugs: A step by step walkthrough of how to reproduce (console/UI/etc). When and how did the problem begin?
* Iterate through the changes in this PR. Why did you implement them this way?
* Was anything tried that didn't work? Anything that reviewers should pay attention to or difficult or tricky that should be explained?
* Does anything special need to happen for deployment?


## "Ready For Review" checklist

You can explicitly use these checklists in PRs to help make sure the basics are covered:

* [ ] PR title accurately summarizes changes
* [ ] New tests were added for isolated methods or new endpoints
* [ ] I opened an issue for any logical followups
* [ ] If this fixes a bug, "Fixes #XXX" is either the very first or very last line of the description.

## Before code review *and after additional commits* during review.

* [ ] Update title and description to account for additional changes
* [ ] All tests green
* [ ] Migrations were tested locally and do the right thing
* [ ] Booted up the branch locally, exercised any new code
* [ ] Percy changes are purposeful or explained
* [ ] Css changes are happy on mobile (via Percy is ok)

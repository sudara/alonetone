## Setting up alonetone locally

- Clone this repo
`git clone REPO_GIT`

### MacOS

- `brew install libsndfile lame` (required for id3 tags and waveforms)
- `brew install vips` (required for processing images)
- `brew install yarn` (required for building assets)
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

## CSS Conventions

We have two themes, dark and white. Every piece of UI has to be made for both themes.

Each hex color value used across the site is defined by exactly one variable in `color_mapping.scss`, using a name derived from and synced with [the site's Figma file](https://www.figma.com/file/YdjrVsNumbBsWVo82Wje2h6N/alonetone-white-theme?node-id=0%3A1).

When a selector needs a color, a *new* unique variable name should be used for the color that describes where the color is being used, if it's for background/text, etc: `$view-all-background`

That variable should then be defined in *both* `white.scss` and `dark.scss`. Map that variable to the actual color name. Note that variables are grouped by the filename they are used in. Be sure to put your new variable in the right filename group.

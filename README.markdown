[![Build Status](https://api.travis-ci.com/sudara/alonetone.svg?branch=master)](http://travis-ci.com/sudara/alonetone)
[![Code Climate](https://api.codeclimate.com/v1/badges/d1f4fb0a4b8690332e86/maintainability)](https://codeclimate.com/github/sudara/alonetone/maintainability)

[![View performance data on Skylight](https://badges.skylight.io/problem/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)
[![View performance data on Skylight](https://badges.skylight.io/typical/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)
[![View performance data on Skylight](https://badges.skylight.io/rpm/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)


Bug reporting provided by Bugsnag's [open source program](https://www.bugsnag.com/open-source/).

Cross-browser testing donated by
<img src="https://cdn.rawgit.com/sudara/alonetone/master/app/assets/images/promo/browserstack.svg" height="25"/>

## The future is bright

[alonetone](https://alonetone.com) is an independent music platform, allowing musicians to host and distribute their music in a non-commercial, easy-to-use environment.

alonetone launched in January 2008 (around the same time as soundcloud).

As of 2018, we host 70,000 tracks from 5500 musicians. We have delivered over 5 million mp3s to real listeners (not google and spambots, we are strict about excluding em!)

### Bug reporting

We use [Github Issues](http://github.com/sudara/alonetone/issues) to submit bugs and keep track of our work.

### Our goal?

To create and run the best online home a musician could want to have. To provide them with the tools they need to reach  listeners and network with other artists — without the stank of commercialism, startup flava, ads, growth hacking motives, etc.

We strive to build:

* An easy to use, straightforward, intuitive, and consistent interface. Grandma-friendly (Yes, my grandma does use alonetone).
* Attractive to look at. UI-first feature building. Designer always involved.
* An open-source rails app that is easy to setup, adheres to best practices and can serve as good example.
* Practical, useful tools and services for musicians — without too much clutter and junk (no facebook integration, etc)
* Encourage artist exploration and a sense of community: encouragement to stick around vs. cliqueyness
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features).

New Features must prove themselves and obey the above principles — not just be built because it sounds cool or would be fun to hack on. We have said "no" to many "intuitive" or "easy" features like threaded comment replies because they would compromise or distract from the above goals.

For more info on alonetone, visit [the alonetone faq](https://alonetone.com/about)

### Current tech

* Rails 5.2
* [Stimulus js](http://stimulusjs.org)
* [Howler js](http://howlerjs.com)

### Current feature set

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download (powered by amazon s3)
* Artist browsing
* Track browsing by popularity, who you are following, most favorited, etc.
* Tracking of listens and providing useful feedback and statistics to artists
* One-way commenting system (No inline relpies. No threaded comments. No "pms")
* Feeds for iTunes podcasts and offsite flash players

## Features wanted

### On the fly zip downloads of playlists via nginx mod\_zip
This is very easy. Already implemented on Ramen Music. Essentially just is a having a controller generate a text file of filenames that nginx interrupts and uses to construct a zip that's sent back to the client.

### Better discovery though tags
It's high time. We're small fries perhaps (40k tracks) but we lack any categorization outside of playlists and users. The community has decided NO GENRES and after a bunch of discussion, we've decided going with tags (chosen by the uploader) is likely best. However, problems ensue, including:
  1) If it's a free for all, won't it just be like genres, but messy?
  2) Should the tags  be moderated and exclude genres?
  3) What to do about tagging all the old music, should moderators be able to adjust and add tags for the lazy users/old tracks?
  4) Should there be a maximum enforced for UI purposes?

This is more than just programming, it's ultimately a UI issue. We can look to Ramen's tag implementation (4-5 maximum, taking up 1-2 lines) for inspiration, but it's very easy to do this wrong.

### Better overall alonetone stats page.
We need to expose a bit more info to the admins/mods. We want to see how signups/assets/comments are trending to help us catch anything strange or cool. But we also just want to know some useful stuff.

### User stats page
Partial implementation/proof of concept was working on rails 2 branch. Basically, a track-by-track table-view of listens, downloads, sources, etc, along with a graph over time for each track.

### A way to manage blacklisted IPs in the backend.
We get trouble with downloading bots, spambots. We have manually hardcoded IPs in the source, specefically to prevent downloading mp3 and wasting our bandwidth. We need to create a UI so this can be managed by a non-techie moderator. Also, we need to provide logged in users with a "report" action on their listens if they notice sketchy behavior, so it can go upstream to the mods.

## Nomenclature and Historical Baggage That Can And Should Change

* The `Asset` model refers to an mp3, `Track` is an entry in a `Playlist`
* Playlists are either albums or mixes depending on a boolean, determined `after_update`
* The home page is `assets#latest`
* The new theme has views prefixed with `_white`
* Too many views are in `shared/`
* Some features are behind `greenfield_enabled?` flag on User
* "Greenfield" is what we called the initial development of a new frontend (listenapp.com) that rode on top of alonetone. We've now pulled those features into alonetone itself. We still need to remove the engine and deal with the content on listenapp.com, such as migrating `Post` content to `Asset#description`. Luckily only 5-6 albums there.

## Want to deploy alonetone on your own server?

It won't work unless:

* You know ruby on rails well (Been doing it for more than a few months).
* You have deployed rails applications before, and are comfortable with that.
* You are willing to spend 20+ hours removing our branding and logo and site-specific code.

We get a LOT of requests from people asking if we can help them setup this "script" because they want an alonetone for a certain region of the world, or in another language.

Please understand that alonetone is open-source as an educational tool, to encourage collaboration, and for transparency. It is not intended as a white-label solution. If you are serious about getting a copy in production, it's going to take lots of work (40+ hours).

**If you still decide to try, keep in mind we are unable to provide ANY support**

## Want to help make alonetone.com awesome?

Sweet, now we are talkin'!

First, [sign up for an account](https://alonetone.com) and start digging in.

Second, hop into our [Slack chat room](https://join.slack.com/t/alonetone/shared_invite/enQtNDE4ODIzMzExNjIyLWFmOWZiZGZlMWRiODZjN2FjNWVlM2E3YWY0ODM0ODlhNjUzMzA3ODFjYzI0NDNmNWIxOWM4MDIxZWFmNWZhNTI) or email us at support@alonetone.com

Thirdly, fork away on github.

### Setup alonetone locally on macOS


- Clone this repo
`git clone REPO_GIT`

- `brew install libsndfile lame` (required for id3 tags and waveforms)

- Install gems
`bundle install`

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

#### Issues and workaround:

- No sound on development? Set `play_dummy_mp3s: true` in alonetone.yml
- Seeing the following yarn error?
```
  Your Yarn packages are out of date!
  Please run `yarn install` to update.
```

Make sure you have the latest version of `npm` and `node`.
```
brew install yarn
yarn install
```

#### Logging in

After the bootstrap data is loaded, you can login using the test account. Username is "admin" and password is "testing123"

After login, click on the "Upload" button to upload your first mp3.

## License

The alonetone source code is released under the MIT license.

"alonetone", "alonetone.com" and the alonetone logo are copyright Sudara Williams 2008-2018 and may not be used without permission.

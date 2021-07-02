[![Build Status](https://github.com/sudara/alonetone/workflows/Specs%20and%20Percy/badge.svg)](https://github.com/sudara/alonetone/actions)
[![Code Climate](https://api.codeclimate.com/v1/badges/d1f4fb0a4b8690332e86/maintainability)](https://codeclimate.com/github/sudara/alonetone/maintainability)
[![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/alonetone/alonetone)

[![View performance data on Skylight](https://badges.skylight.io/problem/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)
[![View performance data on Skylight](https://badges.skylight.io/typical/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)
[![View performance data on Skylight](https://badges.skylight.io/rpm/QMmsxBDrac9Q.svg)](https://oss.skylight.io/app/applications/QMmsxBDrac9Q)


Bug reporting provided by Bugsnag's [open source program](https://www.bugsnag.com/open-source/).

Cross-browser testing donated by
<img src="https://cdn.rawgit.com/sudara/alonetone/master/app/assets/images/promo/browserstack.svg" height="25"/>

## The future is bright

[alonetone](https://alonetone.com) is an independent music platform, allowing musicians to host and distribute their music in a non-commercial, easy-to-use environment.

alonetone launched in January 2008 (around the same time as soundcloud).

As of 2020, we host 80,000 tracks from 6500 musicians in production. We have delivered over 5 million mp3s to real listeners (not google and spambots, we are strict about excluding em!)

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

### Current stack

* Rails 6.1
* [Stitches](http://github.com/sudara/stitches) for audio playback
* Sidekiq for jobs
* Active Storage & s3
* Fastly for CDN image delivery and thumbnailing
* [Hotwire Turbo](https://turbo.hotwire.dev/) and [Stimulus js](http://stimulusjs.org) 2.0

### Current feature set

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download (powered by amazon s3)
* Artist browsing
* Track browsing
* Tracking of listens
* One-way commenting system (No inline replies. No threaded comments. No DMs.)

## Want to deploy alonetone on your own server?

It won't work unless:

* You know ruby on rails well (Been doing it for more than a few months).
* You have deployed rails applications before, and are comfortable with that.
* You are willing to spend 20+ hours removing our branding and logo and site-specific code.

We get a LOT of requests from people asking if we can help them setup this "script" because they want an alonetone for a certain region of the world, or in another language.

Please understand that alonetone is open-source as an educational tool, to encourage collaboration, and for transparency. It is not intended as a white-label solution. If you are serious about getting your own copy in production, it's going to take lots of work (100+ hours).

**If you still decide to try, keep in mind we are unable to provide ANY support**

## Want to help make alonetone.com awesome?

Sweet, now we are talkin'!

First, [sign up for an account](https://alonetone.com) and start digging in.

Second, check out [CONTRIBUTING.md](CONTRIBUTING.md)

## License

The alonetone source code is released under the MIT license.

"alonetone", "alonetone.com" and the alonetone logos are copyright Sudara Williams 2008-2020 and may not be used without permission.

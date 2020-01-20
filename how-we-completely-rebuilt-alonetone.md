# How we completely rebuilt a 10 year old Rails app while keeping it running in production

## Context

[Alonetone](alonetone.com) is atypical for an open-source project. It's not a tool that other devs use or run. It's a music platform Rails app that's been [running in production](alonetone.com) for over a decade.

It's a free service to the public, providing a non-commercial environment for artists to host their music.

I built and deployed and maintained the app myself (it wasn't until 2019 that I stopped committing to master). I paid out of pocket for design (@smoofles) and later css (@ofsound). In 2019, during the peak of this rebuild we were a team of 6.

I personally paid others market rate for their work out of my savings as a consultant.

## Tiny bit of history

We launched in 2008 (around the same time as Soundcloud). The goal was the same: make music hosting for artists easy and free. I thought I was just building a tool for musicians. I learned the hard way that I was running a full fledged platform (support! community! trolls! drama! spam!).

Over the last decade, a bunch of alternatives came online. I directed my attention elsewhere and alonetone had a period where it was essentially unmaintained and unmoderated. At no point did the app go offline, but activity died down, bugs didn't get fixed, etc. We did have a few bursts of work to keep it on "life support" (keeping the rails framework up to date, moving from clunky image sprites to css3, moving from prototype to jquery) over the years, but only enough to keep things running.

## Greenfield

In 2015, [@wioux](github.com/wioux) and I [prototyped a new UI](https://github.com/sudara/alonetone/commit/8819360b6d8a3a691c37e49ba94d30cbd281147d), building it as a Rails engine within the same app. Using the same database, we hosted the new UI on a new domain.

That allowed us to try something new without disturbing existing users. It felt great to greenfield things and we loved the new version. However, the Rails engine paradigm was awkward and we wanted to bring the new UI to existing users, so we ended up deciding we should  [bring the new changes back into the main app](https://github.com/sudara/alonetone/commit/5ed4f4d666bfd2015ff3aae11673839caaefc886#diff-352bb6dc41f859effed43834cbc5b502) in 2017.

This turned into a 2 year long complete overhaul of the app with the following goals:

## Goals

1. Modernize every single component of the application, in place, without bothering users.
2. Create a new white theme: Strip down the old UI, keeping as much of the UX as possible, while paying special attention to making things mobile friendly.
3. Add new UI: Design and integrate new UI with the old, keeping everything in the old UI that worked well (if it ain't broke....)
4. Create a dark theme (the site was dark to begin with)

## Enlisting help

There were 6 of us working on the app in 2019:

@smoofles
Designer

recreate and strip down the old design in [Figma](https://www.figma.com/file/YdjrVsNumbBsWVo82Wje2h6N/alonetone-white-theme?node-id=0%3A1), and then build it back up again with new

@ofsound
Frontend/CSS

Our job was to create a new css framework for the site, recreating and stripping down the current css, while bringing in new changes from the design. This was a very slow and steady process, with 150 hours of billed work in 2018, 250 hours in 2019.

@manfred
Refactoring Backend
180 hours


@jenya
Maintaining Backend

@phasesevencomics
Illustration



## How the stack changed

In addition to completely new css, a new theme and the new UI, almost everything else about the project changed as well:

| Component         | Old Stack         | New Stack |
|-------------------| -----------------| ------------- |
| Design            | Illustrator/Photoshop | [Figma — public](https://www.figma.com/file/YdjrVsNumbBsWVo82Wje2h6N/alonetone-white-theme?node-id=0%3A1) in 2017 |
| Project Management | Basecamp        | [Github Issues](https://github.com/sudara/alonetone/issues) in 2019 |
| Backend Framework | Rails 5.1.2      | [Rails 6](#455) March 2019   |
| JS Framework.     | Jquery + LowPro (<3) | [Webpack](2322537652c0f1e05a75fedaffbd59f45b9d013a) & [Stimulus](031757f36b9204de6508b6b68ac50ed0bf912e5e) |
| CSS               | Sass             | Sass w/ Components + Variables |
| Job Queue         | n/a              | [Sidekiq](52c5fb494a3d7b045a98f51ee84e43ed46670ff0) & ActiveJob |
| Storage           | Paperclip        | [ActiveStorage](#572) in Sept 2019|
| Image Thumbnailing | ImageMagick     | [Fastly](#572) in Sept 2019 (vips locally) |
| Image CDN         | Cloudfront       | [Fastly](#572) in Sept 2019 |
| Audio Playback    | Soundmanager     | [Howler](1b70d22af282ef8cee80aeff35a6b044e5004cc9) in 2018, [Stitches](http://github.com/sudara/stitches) in TBD 2020 |


## Challenges

* To make life easier, we tried to reuse as much HTML as possible and focus on writing new css/js. This was a constant compromise. We often ended up often having 2 variants of the views, the default rails ones and ones with a `_white` suffix (the new theme was white instead of dark). To make matters worse, the new views sometimes were sometimes just a fork of the old ones, vs. fresh new html.

* Mobile. Mobile. Mobile. The 2008 site obviously was not mobile friendly. It cannot be overstated how much effort it takes to translate a web application into something that is fully featured on mobile. In many cases, we had to change fundamental approach.

* I had to catch up with ES6+, learn the Stimulus framework and I decided to [write my own low level HTML audio player](http://github.com/sudara/stitches), as browser changes made it increasingly more difficult to do simple things like play a playlist of audio files.

* Having jobs meant work came in bursts. Although we kept thinking "sprint!" it became very clear we were running a marathon.

## Upsides

* We hit all of our goals, and more. Because timeframe wasn't locked, we felt free to follow our muse and let scope of the rebuild increase.
* Keeping the new work behind a feature toggle was a Good Idea. A lot of old users held out on the old theme until the last minute. They did not like the new stuff when they tried it.
* I got to work with a bunch of fantastic people. Lots of things were accomplished that I couldn't have done on my own.

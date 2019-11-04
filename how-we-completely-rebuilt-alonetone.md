# How we completely rebuilt a 10 year old Rails app while keeping it running in production

## Context

Alonetone is a really atypical open-source app for 3 reasons:

1. It's open source, but it's not a tool that other devs use or run. Instead it's a music platform that's been running in production for over a decade.

2. That app is free, providing a non-commercial location for artists to host music.

3. I built and deployed and maintained the app myself. It wasn't until 2019 that I stopped committing to master. I paid out of pocket for design (@smoofles) and later css (@ofsound). In 2019, we are currently a team of 6. I personally pay the others market rate for their work.

## Tiny bit of history

We launched in 2008, at the same time as Soundcloud. We were a simple non-commercial alternative with values with a small but very active community. I thought I was just building a tool for musicians, and learned the hard way I was running a full fledged platform (read: support, community, trolls, spam).

Eventually a bunch of other platforms came online and I focused on other projects. At no point did the app go offline, but activity did die down. It got some more love (css3! moving from prototype to jquery!) over the years, but only just enough to keep things running.

## Greenfield

In 2015, @wioux and I [prototyped what a next version of the app could look like](https://github.com/sudara/alonetone/commit/8819360b6d8a3a691c37e49ba94d30cbd281147d), building it as a Rails engine within the same app, running it off another domain.

It felt great to greenfield things and we loved the new version. It was a bit awkward as an engine running on another domain, but fed by the same db, so I ended up deciding we should  [bring the new changes back into the main app](https://github.com/sudara/alonetone/commit/5ed4f4d666bfd2015ff3aae11673839caaefc886#diff-352bb6dc41f859effed43834cbc5b502) in 2017.

So started a 2 year complete overhaul of the app.

## The goal

1. Modernize every single component of the application, in place, without bothering users.
2. Have a feature toggle so users could stay on the old legacy dark theme and opt-in once the new theme became solid.
3. Rebuild/reskin the old UI (if it ain't broke....) while paying special attention to making things mobile friendly.

## How the stack changed

| Component         | Old Stack         | New Stack |
|-------------------| -----------------| ------------- |
| Design            | Illustrator/Photoshop | [Figma — public](https://www.figma.com/file/YdjrVsNumbBsWVo82Wje2h6N/alonetone-white-theme?node-id=0%3A1) in 2017 |
| Project Management | Basecamp        | [Github Issues](https://github.com/sudara/alonetone/issues) in 2019 |
| Backend Framework | Rails 5.1.2      | [Rails 6](#455) March 2019   |
| JS Framework.     | Jquery + LowPro (<3) | [Webpack](2322537652c0f1e05a75fedaffbd59f45b9d013a) & [Stimulus](031757f36b9204de6508b6b68ac50ed0bf912e5e) |
| CSS               | Sass             | New Sass w/ Components + Variables |
| Job Queue         | n/a              | [Sidekiq](52c5fb494a3d7b045a98f51ee84e43ed46670ff0) & ActiveJob |
| Storage           | Paperclip        | [ActiveStorage](#572) in Sept 2019|
| Image Thumbnailing | ImageMagick     | [Fastly](#572) in Sept 2019 (vips locally) |
| Image CDN         | Cloudfront       | [Fastly](#572) in Sept 2019 |
| Audio Playback    | Soundmanager     | [Howler](1b70d22af282ef8cee80aeff35a6b044e5004cc9) in 2018, [Stitches](http://github.com/sudara/stitches) in TBD 2019 |


## Surprise, it was harder than expected

Some of the challenges:

* To make life easier, we tried to reuse as much HTML as possible and focus on writing new css/js. This was a constant compromise. We often ended up often having 2 variants of the views, the default rails ones and ones with a `_white` suffix (the new theme was white instead of dark). To make matters worse, the new views sometimes were sometimes just a fork of the old ones, vs. fresh new html.

* Mobile. Mobile. Mobile. The 2008 site obviously was not mobile friendly. It cannot be overstated how much effort it takes to translate a web application into something that is fully featured on mobile.

* I had to catch up with ES6+, learn the Stimulus framework and I decided to [write my own low level HTML audio player](http://github.com/sudara/stitches), as browser changes made it increasingly more difficult to do simple things like play a playlist of audio files.

* Having jobs meant work came in bursts. Although we kept thinking "sprint!" it became very clear we were running a marathon.

## Postmortem: What worked

* Feature toggle worked fine. A lot of old users held out on the old theme until the last minute.

## Postmortem: What didn't work

*
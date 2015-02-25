[![Build Status](https://secure.travis-ci.org/sudara/alonetone.png)](http://travis-ci.org/sudara/alonetone)
[![Code Climate](https://codeclimate.com/github/sudara/alonetone.png)](https://codeclimate.com/github/sudara/alonetone)
## The future is bright

[alonetone](http://alonetone.com) is an independent music platform, allowing musicians to host and distribute their music in a non-commercial, easy-to-use environment.

alonetone launched in January 2008. As of 2015 it hosts over 58,000 tracks from 4500 musicians. We have delivered over 4.5 million mp3s to real listeners (not google and spambots, we are strict about excluding em!)


### Bug reporting 

We use [Github Issues](http://github.com/sudara/alonetone/issues) to submit bugs and keep track of our work.

### Our goal?

To create and run the best online home a musician could want to have. To provide them with the tools they need to reach  listeners and network with other artists — without the stank of commercialism, startup flava, ads, etc. 

We strive to build:

* An easy to use, straightforward, intuitive, and consistent interface. Grandma-friendly (Yes, my grandma does use alonetone).
* Attractive to look at. UI-first feature building. Designer always involved.
* An open-source rails app that is easy to setup, adheres to best practices and can serve as good example.
* Practical, useful tools and services for musicians — without too much clutter and junk (no facebook integration, etc)
* Encourage artist exploration and a sense of community: encouragement to stick around vs. cliqueyness
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features).

New Features must prove themselves and obey the above principles — not just be built because it sounds cool or would be fun to hack on. We have said "no" to many "intuitive" or "easy" features like threaded comment replies because they would compromise or distract from the above goals. 

For more info on alonetone, visit [the alonetone faq](http://alonetone.com/about)

### Current tech

* Rails 4.2
* jQuery
* SoundManager 2 (for flash + html5 playback)


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

### Browse All Playlists
Low hanging fruit, boys and girls! Shoulda been a 2008 feature :)

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

### Groups. 
Talk with Sudara about this. There's a partial half-hearted implementation. 


### Remove alonetone branding from the code
It would be nice to separate the alonetone branding, email address, url, and so on — out into config files.

## Want to deploy alonetone on your server?

![Sorry script kiddies](https://img.skitch.com/20120908-1exaxnmix5mb82xaq32tjnrja.png)

It's not going to happen unless:

* You know ruby on rails well (Been doing it for more than a few months).
* You have deployed rails applications, and are comfortable with that.
* You are willing to spend 20+ hours removing our branding and logo and site-specific things from the code.

We get a LOT of requests from rails n00bs asking if we can help them setup this "script" because they want an alonetone for a certain region of the world, or in another language. 

Please understand that alonetone is open-source as an educational tool, to encourage collaboration, and for transparency. It is not intended as a white-label solution. If you are serious about getting a copy in production, it's going to take lots of work (like 40+ hours) since it's not intended for that purpose.

**If you still decide to try keep in mind we are unable to provide ANY support** 

## Want to help make alonetone.com awesome?

Sweet, now we are talkin'!

First, [sign up for an account](http://alonetone.com) and start digging in.

Second, hop into our Campfire chat room or email us at support@alonetone.com

Thirdly, fork away on github.

### Setup alonetone on localhost


1) clone

2) bundle 

3) Create needed config, database, and load db/seeds:

      rake setup
			
4) rails s


Note: alonetone uses 3 config files that are created by 'rake setup'


      alonetone.yml (contains the application "secret" and app-specific settings)
      database.yml
      newrelic.yml (for performance tracking)


#### Logging in

After the bootstrap data is loaded, you can login using the test account. Username is "admin" and password is "testing123"

After login, click on the "Upload" button to upload your first mp3.

## License 

The alonetone source code is released under the MIT license. 

"alonetone", "alonetone.com" and the alonetone logo are copyright Sudara Williams 2008-2013 and may not be used without permission.

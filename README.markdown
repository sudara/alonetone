[![Build Status](https://secure.travis-ci.org/sudara/alonetone.png)](http://travis-ci.org/sudara
/alonetone)
[![Code Climate](https://codeclimate.com/github/sudara/alonetone.png)](https://codeclimate.com/github/sudara/alonetone)
## The future is bright

[alonetone](http://alonetone.com) is at independent music platform, providing free services for musicians wanting to host and distribute their music in a non-commercial easy-to-use environment.

alonetone  launched in January 2008. As of 2013 it hosts over 48,000 songs from over 3500 musicians and has delivered over 3 million mp3s (to real listeners, not google and spambots!)

## Give us some dev love

Warm the hearts of musicians worldwide by working the *only* open-source rails app that provides musicians with a free home, a connection to each other and their friends/listeners.

### Bug reporting 

We use [Github Issues](http://github.com/sudara/alonetone/issues) to submit bugs and keep track of our work.

### Our goal?

To create and run the best online home a musician could want to have. To provide them with the tools they need to reach  listeners and network with other artists—without the stank of commercialism, startup flava, ads, etc. Yup, we're half hippie communists. 

Here is what we strive to build:

* An easy to use, straightforward, intuitive, and consistent interface. Grandma friendly.
* Attractive to look at. UI-first feature building. Designer always involved.
* Provides musicians with practical, useful tools and services—without too much junk (no facebook integration, etc)
* Provides listeners and first time site visitors with a 'hook' into their first taste of alonetone music and helps them explore the site in an intelligent and guided way
* Encourage artist exploration and the feeling to stick around
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features).
* New Features must prove themselves and obey the above principles — not just be built because it sounds cool or would be fun to hack on.

For more info, visit [the alonetone faq](http://alonetone.com/about)

### Current tech

* Rails 3.2.12
* jQuery
* SoundManager 2 (for flash + html5 playback)


### Current feature set

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download (powered by amazon s3)
* Artist browsing
* Track browsing by popularity, who you are following, most favorited, etc.
* Tracking of listens and providing useful feedback and statistics to artists
* One-way commenting system (No inline relpies. No private messaging. No threaded comments.)
* Feeds for iTunes podcasts and offsite flash players

## Features wanted

### Everything moved to asset pipeline.
Yeah? Yeah.

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


## Want to setup alonetone on your server?

Unless...

* You know ruby on rails VERY well (Been doing it for more than a few months).
* You have deployed rails applications, and are comfortable with that.
* You are willing to spend 20+ hours removing our branding and logo and site-specific things from the code.

Then...

![Sorry script kiddies](https://img.skitch.com/20120908-1exaxnmix5mb82xaq32tjnrja.png)

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

After the bootstrap data is loaded, you can login using the test account (username=test, password=test).

After login, click on the "Upload" button to upload your first mp3.

## License 

The alonetone source code is released under the MIT license. 

"alonetone", "alonetone.com" and the alonetone logo are copyright Sudara Williams 2008-2012 and may not be used without permission.

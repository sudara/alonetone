## The future is bright

[alonetone](http://alonetone.com) is at independent music platform, providing free services for musicians wanting to host and distribute their music in a non-commercial easy-to-use environment.

alonetone was launched in January 2008. As of September 2012 it hosts over 40,000 songs from over 3000 musicians and has delivered over 2.5 million mp3s (to real listeners, not google and spambots!)

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

* Rails 3.2.8
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

### Features wanted

#### Everything moved to asset pipeline.
Yeah? Yeah.

#### Browse All Playlists
Low hanging fruit, boys and girls! Shoulda been a 2008 feature :)

#### On the fly zip downloads of playlists via nginx mod\_zip
This is very easy. Already implemented on Ramen Music. Essentially just is a having a controller generate a text file of filenames that nginx interrupts and uses to construct a zip that's sent back to the client.

#### Better overall alonetone stats page. 
We need to expose a bit more info to the admins/mods. We want to see how signups/assets/comments are trending to help us catch anything strange or cool. But we also just want to know some useful stuff.

#### User stats page
Partial implementation/proof of concept was working on rails 2 branch. Basically, a track-by-track table-view of listens, downloads, sources, etc, along with a graph over time for each track. 

#### A way to manage blacklisted IPs in the backend. 
We get trouble with downloading bots, spambots. We have manually hardcoded IPs in the source, specefically to prevent downloading mp3 and wasting our bandwidth. We need to create a UI so this can be managed by a non-techie moderator. Also, we need to provide logged in users with a "report" action on their listens if they notice sketchy behavior, so it can go upstream to the mods.

#### Groups. 
Talk with Sudara about this. There's a partial half-hearted implementation. 

### Want to help out?

First, [sign up for an account](http://alonetone.com) and start digging in.

Second, hop into our Campfire chat room or email us at support@alonetone.com

Thirdly, fork away on github.

### Setting up alonetone on localhost

This is *not* a task for Rails newbees. This is not a 'clone script' that is easy to setup on your servers. We cannot provide ANY support   so please do not email us requesting this.

Unless you have LOTS of experience with rails, you should not consider trying to set this up.

If you live and breathe rails and you want to get jiggy:

alonetone uses 6 config files:

      alonetone.yml (contains the application "secret" and app-specific settings)
      database.yml
      amazon_s3.yml (used in production, by default development mode runs with :file_system storage)
      defensio.yml (spam protection, ignored in development)
      facebooker.yml (for facebook app, ignore this in general for now)
      newrelic.yml (for performance tracking)

These files will be created for you the first time you run any rake task. 

#### Gem installation


We use bundler. You'll need imagemagick installed.  If you have the Bundler gem installed, you can install all of the dependencies like so:

   `bundle install`



#### Database setup

Then, you can create a development database, run all migrations and load some bootstrap data with:

      rake db:remake

#### Logging in

After the bootstrap data is loaded, you can login using the test account (username=test, password=test).

You will see session and current\_user information at the end of each page after login. You can turn it off by changing show\_debug_info to false in alonetone.yml.

After login, click on the "Upload" button to upload your first mp3.

### License 

The alonetone source code is released under the MIT license. 

"alonetone", "alonetone.com" and the alonetone logo are copyright Sudara Williams 2008 and may not be used without permission.

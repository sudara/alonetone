## The future is bright

[alonetone](http://alonetone.com) is a growing independent music platform, providing free services for musicians wanting to host and distribute their music in a non-commercial easy-to-use environment.

alonetone was launched in January 2008. As of September 2011 it hosts over 30,000 songs from 2500 musicians and has delivered over 2 million mp3s to real listeners. 

## Give us some dev love

Warm the hearts of musicians worldwide by working the *only* open-source rails app that provides musicians with a free home, a connection to each other, to their listeners, and to a source of inspiration. 

### Bug reporting 

We use [Github Issues](http://github.com/sudara/alonetone/issues) to submit bugs and keep track of our work.

### Our goal?

To create and run the best online home a musician could want to have, providing them with the tools they need to reach their listeners and network with other artists, without the stank of commercialism or startup flava. Yup, we're half hippie communists. 

How do we reach this goal?

* It must be easy to use, straightforward, intuitive, and consistent (grandma-friendly)
* It must be attractive to look at 
* It provides musicians with practical, useful and inspiring tools and services
* It provides listeners and first time site visitors with a 'hook' into their first taste of alonetone music and helps them explore the site in an intelligent and guided way
* It encourages artist exploration and the feeling to stick around
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features)

For more info, visit [the alonetone faq](http://alonetone.com/about)

### Current feature set

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download (powered by s3)
* Artist browsing
* Tracking of listens and providing useful feedback and statistics to artists
* Commenting system
* Feeds for iTunes podcasts and offsite flash players

### Current tech

* Rails 2.3.11
* jQuery and LowPro
* SoundManager 2 (for flash mp3 playback)
* SASS

### Want to help us?

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

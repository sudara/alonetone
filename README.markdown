## The future is bright

[alonetone](http://alonetone.com) is a growing independent music platform, providing free services for musicians wanting to host and distribute their music in a non-commercial easy-to-use environment.

alonetone was launched in January 2008

## alonetone is looking for more love

Are you a musician / music lover with Rails or UI/design chops? 

Help us to build the best indy music platform out there.

If you are interested, [sign up over at alonetone](http://alonetone.com/signup) and check out what is there. We could always use more usability/UI/design help, basic testing, general feedback, and eventually, some more Rails love. 

Secondly, please email me at sudara at alonetone dot com.

### Bug reporting 

We use [lighthouse](http://alonetone.lighthouseapp.com) to submit bugs and keep track of our work

### The goal?

To create and run the best online home a musician could want to have, providing them with the tools they need to reach their listeners and network with other artists, without the umbrella of a corporation.

How do we reach this goal?

* It is easy to use, intuitive, and consistent (grandma-friendly)
* It is attractive to look at 
* It provides musicians with practical, useful and inspiring tools and services
* It provides listeners and first time site visitors with a 'hook' into their first taste of alonetone music and helps them explore the site in an intelligent and guided way.
* It encourages artist exploration 
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features)

For more info, visit [the alonetone faq](http://alonetone.com/about)


### Current feature set

Really, only the very basics are implemented.

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download
* Basic artist browsing
* Tracking of listens and providing useful feedback to artists
* Very basic commenting system
* Facebook integration
* Feeds for iTunes podcasts and offsite flash players

### Current tech

* Rails 2.1
* Rspec
* jQuery and LowPro
* SoundManager 2 (for flash mp3 playback)
* SASS (the cool stylesheet thing from the haml folks)

### Want to join forces?

First of all, talk to Sudara by emailing Sudara at alonetone com

Secondly, [sign up for an account](http://alonetone.com) and start digging in.

Thirdly, fork away on github.

### Playing with alonetone on localhost

This is *not* a task for Rails newbees. 

I've had multiple requests asking me to walk folks through setting up alonetone locally. Unless you have some experience with rails, it's just not going to be worth it unless you have a lot of time to invest.

If you do want to get jiggy and setup alonetone locally, the best thing to do is to contact me first, as things are ever-changing. 

alonetone uses 6 config files:

    alonetone.yml (contains the application "secret" and app-specific settings)
    database.yml
    amazon_s3.yml (used in production, by default development mode runs with :file_system storage)
    defensio.yml (spam protection, ignored in development)
    facebooker.yml (for facebook app, ignore this in general for now)
    newrelic.yml (for performance tracking)

These files will be created for you the first time you run any rake task. 

You'll need some gems, at least:

      rmagick
      haml
      json
      ruby-mp3info
      googlecharts
      aws-s3 (if you use Amazon S3 to store files)
      rubyzip (for extracting mp3s from zip files)
      mocha (for rspec)
      
You can let the system install all required gems for you using following command:

      rake gems:install

NOTE: On a Windows install using InstantRails with Rails 2.2.2 and RubyGems 1.3, an error such as 'uninitialized constant ApplicationController::ALONETONE' might present itself when using the 'rake gems:install' command. However, I found that if you install all of the gems manually that you can ignore this error message.

You can also install them manually:

			sudo gem install rmagick haml json ruby-mp3info aws-s3 rubyzip mocha

You may need to install imagemagick before rmagick. If you are using Ubuntu you can run 'sudo apt-get install imagemagick libmagick9-dev'. If you are on a Mac, you can 'sudo port install imagemagick'
			
You'll need to install rails 2.1 gem or have a copy in the vendor directory.

Then, you can create a development database, run all migrations and load some bootstrap data with:

      rake db:remake


After bootstrap data is loaded, you can login using test account with username=test, password=test.

You will see session and current\_user information at the end of each page after login. You can turn it off by changing show\_debug_info to false in alonetone.yml

After login, click on "Upload" button to upload your first mp3.

### License 

The alonetone source code is released under the MIT license. 

"alonetone", "alonetone.com" and the alonetone logo are copyright Sudara Williams 2008 and may not be used without permission.
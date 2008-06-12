## The future is bright

[alonetone](http://alonetone.com) is a growing independent music platform, providing free services for musicians wanting to host and distribute their music in a non-commercial easy-to-use environment.

alonetone was launched in January 2008 as Sudara's side project.

## alonetone is looking for more love

We are growing and need your help.

Are you a musician / music lover with Rails or UI/design chops? 

Help us to build the best indy music platform out there.

If you are interested, [sign up over at alonetone](http://alonetone.com/signup) and check out what is there. We could always use more usability/UI/design help, basic testing, general feedback, and eventually, some more Rails love. 

Secondly, please email me at sudara at alonetone dot com.

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

First of all, talk to me. 
  You can send me electronic mail. Sudara at alonetone com

Secondly, [sign up for an account](http://alonetone.com) and start digging in.

### Playling with alonetone on localhost

I won't lie. This is not a task for Rails newbees. I've had multiple requests asking me to walk folks through setting up alonetone locally. Unless you have some experience with rails, it's just not going to be worth it unless you have a lot of time to invest.

If you do want to get jiggy and setup alonetone locally, the best thing to do is to contact me first, as things are ever-changing. 

You'll need to setup 5 config files for it to run flawlessly:

    alonetone.yml (contains the application "secret" and app specefic settings)
    database.yml
    amazon_s3.yml (you can always ignore this and set Asset and Pic models to use the filesysem)
    defensio.yml (spam protection, you can ignore this in development)
    facebooker.yml (for facebook app, you can ignore this in general)

You'll need some gems, at least:

      rmagick
      haml
      facebooker
      json
      ruby-mp3info
      mocha (for rspec)
      googlecharts
      aws-s3
      rubyzip (for extracting mp3s from zip files)

Then, 
      rake db:migrate

There is no bootstrapper at this time, so you'll probably need to fiddle with it a bit or bug me to make one.

## The future is bright

We live in a world where 1 person in his spare time can provide limitless distribution for hundreds of artists, thousands of songs, millions of copies. 

Truly, we are at the beginning of a revolution in music making.

I invite you to join me in moving music away from countless companies looking to profit from musicians and help me to create the best damn online home for DIY/indy/new musicians.

### The goal?

To create and run best online home a musician could have. 

What would make it the best?

* It is easy to use (grandma-friendly)
* It is attractive to look at
* It provides musicians with practical, useful and inspiring tools and services
* It does not overwhelm folks with TMI (too much information) or TMO (too many options) or TMF (too many features)
* It supports and makes it easy to navigate 1000s of musicians
* The features are developed by the musicians, implemented and refined by the dev team

For more info, visit [the alonetone faq](http://alonetone.com/about)


### Current feature set

Really, only the very basics are implemented.

* Unlimited mp3 uploads for musicians
* Creation of playlists / albums
* MP3 streaming and download
* Basic artist browsing
* Tracking of listens and providing useful feedback to artists
* Very basic commenting system
* Extremely basic Facebook integration
* Feeds for itunes and offsite flash players

Please visit [the alonetone todo list](http://alonetone.com/about/todo) for more juicy details regarding how my life is potentially booked this next year.

### Current tech

* Rails 2.1
* Rspec
* LowPro and Prototype (moving to jquery)
* SoundManager 2 (for flash mp3 playback)
* SASS (the cool stylesheet thing from the haml folks)

### Want to join forces?

First of all, talk to me. 
  You can send me electronic mail. Sudara at alonetone com

Secondly, sign up for an account and browse and get used to the exsiting site:
  http://alonetone.com 

### Set it up

You'll need to setup 6 config files for it to run flawlessly:

    alonetone.yml (contains the application "secret")
    database.yml
    amazon_s3.yml (you can always ignore this and set Asset and Pic to use the filesysem)
    basecamp.yml (for todo list, you don't need it unless you want pages/todo)
    defensio.yml (spam protection)
    facebooker.yml (for facebook app)

You'll need some gems, at least:

      rmagick
      haml
      facebooker
      ruby-mp3info
      mocha (for rspec)
      googlecharts
      aws-s3
      rubyzip (for extracting mp3s from zip files)

Then, 
  rake db:migrate

Until I write a bootstrapper, you'll need to make sure the database has something in it. 
  
If I were you, and I were looking at alonetone and wanting to do anything useful with it....I would email me.
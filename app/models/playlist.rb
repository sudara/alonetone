# == Schema Information
# Schema version: 16
#
# Table name: playlists
#
#  id           :integer(11)   not null, primary key
#  title        :string(255)   
#  description  :string(255)   
#  image        :string(255)   
#  user_id      :integer(11)   
#  tracks_count :integer(11)   
#  created_at   :datetime      
#  updated_at   :datetime      
#  pic_id       :integer(11)   
#  permalink    :string(255)   
#
require 'zip/zip'
require 'zip/zipfilesystem'
class Playlist < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  
  has_one :pic, :as => :picable, :dependent => :destroy
  has_many :tracks, :include => [:asset => :user], :dependent => :destroy, :order => :position
  has_many :assets, :through => :tracks #, :after_add => 
  
  validates_presence_of :title
  validates_length_of :title, :within => 4..100
  validates_presence_of :description
  
  has_permalink :title
   # make sure we update permalink when user changes title
  before_save :create_unique_permalink
  before_update :set_mix_or_album

  def to_param
    "#{self.permalink}"
  end
  
  def dummy_pic(size)
    case size
      when :small then 'no-cover-50.jpg' 
      when :large then 'no-cover-125.jpg'
      when :album then 'no-cover-200.jpg' 
      when nil then 'no-cover-400.jpg'
    end 
  end
  
  def cover(size)
    return dummy_pic(size) unless self.pic && !self.pic.new_record?
    self.pic.public_filename(size)
  end
  
  def has_tracks?
    (self.tracks_count || 0) > 0
  end

  def empty?
    !has_tracks?
  end
  
  def play_time
    Asset.formatted_time(self.tracks.inject(0){|total,track| total += track.asset[:length] if track.asset && track.asset[:length]})
  end
  
  def zip(name = self.permalink, set = self.artist.permalink)
     bundle_filename = "#{RAILS_ROOT}/public/uploads/#{set}-#{name}.zip"



     # set the bundle_filename attribute of this object
     self.bundle_filename = "/uploads/#{set}-#{name}.zip"

     # open or create the zip file
     Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) {
       |zipfile|
       # collect the album's tracks
       self.tracks.collect {
         |track|
           # add each track to the archive, names using the track's attributes
           zipfile.add( "#{set}/#{track.num}-#{track.filename}", "#{RAILS_ROOT}/public#{track.public_filename}")
         }
     }

     # set read permissions on the file
     File.chmod(0644, bundle_filename)

     # save the object
     self.save
  end
  
  def self.latest(limit=5)
    self.find(:all, :conditions => 'playlists.tracks_count > 0', :include => :user, :limit => limit, :order => 'playlists.created_at DESC')
  end
  
  protected 
  
  def set_mix_or_album
    # playlist is a mix if there is at least one track with a track from another user
    self.is_mix = self.tracks.any?{ |track| track.asset.user.id.to_s != self.user.id.to_s}
    true
  end
end

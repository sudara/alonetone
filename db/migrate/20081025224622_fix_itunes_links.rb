class FixItunesLinks < ActiveRecord::Migration
  def self.up
    old_link = 'phobos.apple.com/webobjects/mzstore.woa/wa/viewpodcast'
    new_link = 'phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast'
    User.find(:all, :conditions => 'itunes != ""').each do |broken|
      fix = broken.itunes.gsub(old_link,new_link)
      broken.update_attribute :itunes, fix
    end
  end

  def self.down
  end
end

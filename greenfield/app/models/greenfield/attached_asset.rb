module Greenfield
  class AttachedAsset < ActiveRecord::Base
    belongs_to :post
    has_one :user, :through => :post
    has_one :alonetone_asset, :through => :post, :source => :asset

    # TODO: Need to validate attachment embeds...

    attachment_options = {
      :styles => { :original => ''}, # just makes sure original runs through the processor
      :processors => [:mp3_paperclip_processor],
    }

    if Alonetone.storage == 's3'
      attachment_options[:path] = "/greenfield/:id/:basename.:extension" 
      attachment_options[:s3_permissions] = 'authenticated-read'
    end

    has_attached_file :mp3, attachment_options
    attr_accessible :mp3

    serialize :waveform, Array
    attr_accessible :waveform


    validates_attachment_size :mp3, :less_than => 60.megabytes
    validates_attachment_presence :mp3, :message => 'must be set. Make sure you chose a file to upload!'
    validates_attachment_content_type :mp3, :content_type => ['audio/mpeg', 'audio/mp3'], :message => " was wrong. It doesn't look like you uploaded a valid mp3 file. Could you double check?"

    def length
      Asset.formatted_time(self[:length])
    end

    # This stuff is stubbed for compatibility with Mp3PaperclipProcessor
    attr_accessor :title
    def generate_permalink!; end
  end
end

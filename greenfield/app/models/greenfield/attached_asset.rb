module Greenfield
  class AttachedAsset < ActiveRecord::Base
    belongs_to :post

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

    # This stuff is stubbed for compatibility but should be fixed

    def length; 0; end

    attr_accessor :title
    def generate_permalink!; end
  end
end

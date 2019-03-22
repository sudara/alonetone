module Greenfield
  class AttachedAsset < ActiveRecord::Base
    belongs_to :post
    has_one :user, through: :post
    has_one :alonetone_asset, through: :post, source: :asset

    # TODO: Need to validate attachment embeds...

    attachment_options = {
      styles: { original: '' }, # just makes sure original runs through the processor
      processors: [:mp3_paperclip_processor]
    }

    if Rails.application.remote_storage?
      attachment_options[:path] = "/greenfield/:id/:basename.:extension"
      attachment_options[:s3_permissions] = 'authenticated-read'
    end

    has_attached_file :mp3, attachment_options

    serialize :waveform, Array

    validates_attachment_size :mp3, less_than: 60.megabytes
    validates_attachment_presence :mp3, message: 'must be set. Make sure you chose a file to upload!'
    validates_attachment_content_type :mp3, content_type: ['audio/mpeg', 'audio/mp3'], message: " was wrong. It doesn't look like you uploaded a valid mp3 file. Could you double check?"

    has_one_attached :audio_file

    def permalink
      "#{id}-@attachment"
    end

    def length
      Asset.formatted_time(self[:length])
    end
  end
end

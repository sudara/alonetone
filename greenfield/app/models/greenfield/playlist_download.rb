module Greenfield
  class PlaylistDownload < ActiveRecord::Base
    include Paperclip

    belongs_to :playlist


    # see config/initializers/paperclip for defaults
    attachment_options = {}
    if Alonetone.storage == 's3'
      attachment_options[:path] = ":s3_path"
      attachment_options[:s3_permissions] = 'authenticated-read' # don't want these facing the public
    end

    has_attached_file :attachment, attachment_options
    validates_attachment_presence :attachment, message: 'must be set. Make sure you chose a file to upload!'
    validates_attachment_content_type :attachment, :content_type => ['application/zip', 'application/gzip'],
      message: " was wrong. It doesn't look like you uploaded a valid zip file. Could you double check?"

    def url
      attachment.expiring_url.gsub('s3.amazonaws.com/','')
    end
  end
end

# -*- encoding : utf-8 -*-
class SourceFile < ActiveRecord::Base
  
  belongs_to      :user
  #has_attachment  :storage      => Alonetone.storage, 
  #               :content_type => ['audio/x-aiff','audio/x-wav','application/zip'],
  #               :max_size     => 400.megabytes,
  #               :path_prefix  => File.join(Alonetone.path_prefix, "source_files"),
  #               :s3_access    => :authenticated_read,
  #               :processor    => Alonetone.image_processor 
                  
  validates_as_attachment
end

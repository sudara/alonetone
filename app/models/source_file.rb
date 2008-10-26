class SourceFile < ActiveRecord::Base
  
  belongs_to      :user
  has_attachment  :storage      => ALONETONE.storage, 
                  :content_type => ['audio/x-aiff','audio/x-wav','application/zip'],
                  :max_size     => 150.megabytes,
                  :path_prefix  => File.join(ALONETONE.path_prefix, "source_files"),
                  :s3_access    => :authenticated_read,
                  :processor    => ALONETONE.image_processor 
                  
  validates_as_attachment
end

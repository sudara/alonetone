class SourceFile < ActiveRecord::Base
  
  belongs_to      :user
  has_attachment  :storage => :s3, 
                  :content_type => ['audio/x-aiff','audio/x-wav'],
                  :max_size => 100.megabytes,
                  :path_prefix => "source_file",
                  :s3_access => :authenticated_read
                  
  validates_as_attachment
end

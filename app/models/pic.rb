class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true

  # Pic
  has_attachment :min_size      => 100.bytes,
                 :max_size      => 2048.kilobytes,
                 :resize_to     => 'x400',
                 :content_type  => :image,
                 :storage       => ALONETONE.storage,
                 :path_prefix   => File.join(ALONETONE.path_prefix, "pics"),
                 :processor     => ALONETONE.image_processor,
                 :thumbnails    => { 
                                      :tiny   => [ 25,  25], 
                                      :small  => [ 50,  50], 
                                      :large  => [125, 125], 
                                      :album  => [200, 200] 
                                    }
  
  # not yet it can ;)
  #can_be_cropped
  validates_as_attachment

end

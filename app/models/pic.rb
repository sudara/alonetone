class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true

  # Pic
  has_attachment :min_size => 100.bytes,
                 :max_size => 2048.kilobytes,
                 :resize_to => 'x400',
                 :content_type => :image,
                 :thumbnails => { :tiny => [25,25], :small => [50,50], :large => [125,125], :album=>[200,200] },
                 :storage => :file_system,
                 :path_prefix => 'public/pics',
                 :processor => :Rmagick
  
  # not yet it can ;)
  #can_be_cropped
  validates_as_attachment

end

class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true, :touch => true
  
  # Pic
  #has_attachment :min_size      => 100.bytes,
  #              :max_size      => 2048.kilobytes,
  #              :resize_to     => 'x400',
  #              :content_type  => :image,
  #              :storage       => Alonetone.storage,
  #              :path_prefix   => File.join(Alonetone.path_prefix, "pics"),
  #              :processor     => Alonetone.image_processor,
  #              :thumbnails    => { 
  #                                   :tiny   => [ 25,  25], 
  #                                   :small  => [ 50,  50], 
  #                                   :large  => [125, 125], 
  #                                   :album  => [200, 200] 
  #                                 }

  has_attached_file :pic, {
    :styles => {
      :tiny   => "25x25#", 
      :small  => "50x50#", 
      :large  => "125x125#", 
      :album  => "200x200#", 
      :original => "400x400#"
    },
    :path => "/pics/:id/:basename_:style.:extension"
  }
  validates_attachment_size :pic, :less_than => 3.megabytes, :greater_than => 100.bytes
  validates_attachment_content_type :mp3, :content_type => /image/
end

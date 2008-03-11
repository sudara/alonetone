class <%= class_name %> < ActiveRecord::Base
  has_attachment :min_size => 100.bytes,
                 :max_size => 8048.kilobytes,
                 :resize_to => '800x800>',
                 :thumbnails => { :thumb => '25x25' },
                 :processor => "ImageScience",
                 :storage => :file_system
  can_be_cropped
  validates_as_attachment
end

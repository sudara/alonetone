class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true, :touch => true

  # Default config for has_attached_file can be found in config/initializers
  attachment_options = {
    :styles => {
      :tiny   => "25x25#", 
      :small  => "50x50#", 
      :large  => "125x125#", 
      :album  => "200x200#", 
      :original => "400x400#"
  }}
  # required for production alonetone, to be compatible with rails 2/attachment_fu paths
  attachment_options[:path] = "/pics/:id/:basename_:style.:extension" if Alonetone.storage == "s3"
  has_attached_file :pic, attachment_options

  validates_attachment_size :pic, :less_than => 3.megabytes, :greater_than => 100.bytes
  validates_attachment_content_type :pic, :content_type => /image/
end

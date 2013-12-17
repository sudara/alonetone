class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true, :touch => true

  # Default config for has_attached_file can be found in config/initializers
  attachment_options = {
    :styles => {
      :tiny   => "25x25#", 
      :small  => "50x50#", 
      :large  => "125x125#", 
      :album  => "200x200#", 
      :original => "800x800#"
  }}
  # required for production alonetone, to be compatible with rails 2/attachment_fu paths
  attachment_options[:path] = "/pics/:id/:name_with_style.:extension" if Alonetone.storage == "s3"
  has_attached_file :pic, attachment_options

  validates_attachment_presence :pic, :message => 'must be set. Make sure you chose a file to upload!'
  validates_attachment_size :pic, :less_than => 3.megabytes, :greater_than => 100.bytes
  validates_attachment_content_type :pic, :content_type => /image/
  
  # ids after 69601 have :original style stored as filename_original.jpg instead of filename.jpg
  Paperclip.interpolates 'name_with_style' do |attachment, style|
    if attachment.instance.id.to_i > 69601
      "#{basename(attachment, style)}_#{style || 'original'}"
    elsif style.nil? # original
      basename(attachment, style)
    else
      "#{basename(attachment, style)}_#{style}"
    end
  end
      
  attr_accessible :pic, :picable_type, :picable_id
end

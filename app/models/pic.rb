# == Schema Information
#
# Table name: pics
#
#  id               :integer          not null, primary key
#  pic_file_size    :integer
#  pic_content_type :string(255)
#  pic_file_name    :string(255)
#  parent_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  picable_type     :string(255)
#  picable_id       :integer
#

class Pic < ActiveRecord::Base
  belongs_to :picable, :polymorphic => true, :touch => true

  # Default config for has_attached_file can be found in config/initializers
  attachment_options = {
    :styles => {
      :tiny       => "25x25#",
      :small      => "50x50#",
      :large      => "125x125#",
      :album      => "200x200#",
      :original   => "800x800#",
      :greenfield => "1500x1500#",
      :hq         => "3000x3000#"
  }}
  # required for production alonetone, to be compatible with rails 2/attachment_fu paths
  attachment_options[:path] = "/pics/:id/:name_with_style.:extension" if Alonetone.storage == "s3"
  has_attached_file :pic, attachment_options

  validates_attachment_presence :pic, :message => 'must be set. Make sure you chose a file to upload!'
  validates_attachment_size :pic, :less_than => 5.megabytes, :greater_than => 100.bytes
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

end

# == Schema Information
#
# Table name: pics
#
#  id               :integer          not null, primary key
#  pic_content_type :string(255)
#  pic_file_name    :string(255)
#  pic_file_size    :integer
#  picable_type     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  parent_id        :integer
#  picable_id       :integer
#
# Indexes
#
#  index_pics_on_picable_id_and_picable_type  (picable_id,picable_type)
#

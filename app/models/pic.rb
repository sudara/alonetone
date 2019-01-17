class Pic < ActiveRecord::Base
  belongs_to :picable, polymorphic: true, touch: true
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

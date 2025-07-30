class ReservedWord < ApplicationRecord
  validates :name, presence: true

  def contains(search)
    Regexp.new(name, Regexp::IGNORECASE).match(search)
  end
end

# == Schema Information
#
# Table name: reserved_words
#
#  id          :bigint(8)         not null, primary key
#  name        :string(255)       not null
#  details     :text
#  created_at  :datetime          not null
#  updated_at  :datetime          not null
#
# Indexes
#
#  index_reserved_words_on_name  (name) UNIQUE
#

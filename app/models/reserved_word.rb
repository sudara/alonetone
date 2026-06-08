class ReservedWord < ApplicationRecord
  # Names are admin-entered regexes matched on the signup path, so cap match time against catastrophic backtracking.
  MATCH_TIMEOUT = 0.5

  validates :name, presence: true
  validate :name_is_a_valid_regexp

  def contains(search)
    Regexp.new(name, Regexp::IGNORECASE, timeout: MATCH_TIMEOUT).match?(search)
  rescue RegexpError
    false
  end

  private

  def name_is_a_valid_regexp
    Regexp.new(name) if name.present?
  rescue RegexpError
    errors.add(:name, :invalid_regexp)
  end
end

# == Schema Information
#
# Table name: reserved_words
#
#  id         :bigint(8)        not null, primary key
#  details    :text(65535)
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_reserved_words_on_name  (name) UNIQUE
#

class Feature < ActiveRecord::Base
  include SoftDeletion

  scope :published, -> { where(published: true).order('created_at DESC') }

  has_many :featured_tracks,
    -> { order('featured_tracks.position').includes(:asset) }

  has_many :comments,
    -> { order('created_at DESC') },
    as: :commentable,
    dependent: :destroy

  belongs_to :writer,         class_name: 'User'
  belongs_to :featured_user,  class_name: 'User'

  validates_presence_of :writer, :featured_user

  before_save :create_permalink

  def to_param
    permalink.to_s
  end

  # hackish way to add featured tracks quick and dirty w/ csv

  def featured_tracks_list
    featured_tracks.pluck(:asset_id).join(',')
  end

  def featured_tracks_list=(ids)
    featured_tracks.destroy_all
    ids.split(',').each_with_index do |id, position|
      featured_tracks.create(asset_id: id.to_i, position: position)
    end
  end

  # The following methods help us keep dry w/ comments
  def name
    "#{user.name}'s alonetone feature"
  end

  alias user featured_user

  protected

  def create_permalink
    self.permalink = User.find(featured_user_id).login
  end

  def publish!
    update(published: true, published_at: Time.now)
  end
end

# == Schema Information
#
# Table name: features
#
#  id               :integer          not null, primary key
#  body             :text(16777215)
#  datetime         :boolean
#  permalink        :string(255)
#  published        :boolean          default(FALSE)
#  published_at     :boolean
#  teaser_text      :text(16777215)
#  views_count      :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#  featured_user_id :integer
#  writer_id        :integer
#

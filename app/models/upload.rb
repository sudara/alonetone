# frozen_string_literal: true

# Upload is a service class to deal with incoming uploads.
class Upload
  include ActiveModel::Model
  include ActiveModel::Validations

  # The uploaded file objects (i.e. ActionDispatch::Http::UploadedFile)
  attr_accessor :files

  # The user who initiated the upload.
  attr_accessor :user

  validates :files, :user, presence: true

  def process
    valid?
  end
end

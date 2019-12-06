# frozen_string_literal: true

# Serves resized images roughly in the same way as Fastly works.
class ThumbnailsController < ActionController::Metal
  def show
    thumbnail = Thumbnail.new(params[:key], **image_attributes)
    thumbnail.headers.each { |name, value| response.headers[name] = value }
    thumbnail.write(response.stream)
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  private

  def image_attributes
    params.slice(:crop, :width, :quality).symbolize_keys
  end

  def render_not_found
    self.status = 404
    self.content_type = 'text/plain'
  end
end

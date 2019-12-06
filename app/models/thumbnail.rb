# frozen_string_literal: true

require 'vips'

# Crops, resizes, and re-compresses images to a thumbnail version.
#
#   Thumbnail.new('bwux2resludpcd4vfzuve6hk726', crop: '1:1', width: 124, quality: 68)
class Thumbnail
  # Create a thumbnail for the Blob with specified key.
  #
  #   * crop: specify a crop ratio when only using parts of the image, ie. '16:9' or '1:1'.
  #   * width: maximum width for the resulting image (doesn't upscale)
  #   * quality: JPEG quality in percentage (100 is maximum)
  def initialize(key, crop: nil, width: nil, quality: nil)
    @key = key
    @transformation = { crop: crop, width: width, quality: quality }.compact
  end

  def headers
    {
      'Content-Type' => 'image/jpeg',
      'ETag' => etag,
      'Expires' => expiration.seconds.from_now.httpdate,
      'Cache-Control' => cache_control
    }.compact
  end

  def write(out)
    out.write(jpeg)
  end

  # Calculates the maximum dimensions with the specified crop ratio that fits inside the specified
  # width and height.
  #
  #   crop_dimensions(width: 200, height: 100, crop: '1:4') #=> [25, 100]
  def self.crop_dimensions(width:, height:, crop:)
    crop_ratio = crop.split(':').map(&:to_f).inject(&:/)
    image_ratio = width.to_f / height
    [
      crop_ratio > image_ratio ? width : (height * crop_ratio).floor,
      crop_ratio > image_ratio ? (width / crop_ratio).floor : height
    ]
  end

  private

  def original
    ActiveStorage::Blob.find_by!(key: @key).download
  end

  def original_image
    @original_image ||= Vips::Image.new_from_buffer(original, "")
  end

  def jpeg
    # Vips automatically applies EXIF rotation to images when the Image is initialized so we don't
    # have to explicitly specify this operation.
    if crop
      cropped_and_resized_image
    elsif width
      resized_image
    else
      original_image
    end.jpegsave_buffer(
      # The following are JPEG writer options: JPEG quality, optimize JPEG to reduce file size,
      # leave EXIF data out of the file.
      Q: quality, optimize_coding: true, strip: true
    )
  end

  def crop_dimensions
    self.class.crop_dimensions(
      crop: crop, width: original_image.width, height: original_image.height
    )
  end

  def cropped_and_resized_image
    cropped = original_image.smartcrop(*crop_dimensions)
    width ? cropped.thumbnail_image(width) : cropped
  end

  def resized_image
    Vips::Image.thumbnail_buffer(
      original, width,
      # Downsize is Vips language for downscale. Specifying `down: :size` means that an image is
      # never upscaled to match the specified width.
      size: :down
    )
  end

  # Maximum age of thumbnail cache in seconds.
  def expiration
    3600
  end

  def etag
    '"' + Digest::SHA1.hexdigest([@key, rand(10), @transformation].inspect) + '"'
  end

  def cache_control
    "max-age=#{expiration}, public"
  end

  def crop
    @transformation[:crop]
  end

  def width
    width = @transformation[:width]
    width ? width.to_i : nil
  end

  def quality
    @transformation.fetch(:quality, 65).to_i
  end
end

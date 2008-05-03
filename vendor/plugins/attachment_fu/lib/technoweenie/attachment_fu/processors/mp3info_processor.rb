require 'mp3info'
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module Mp3infoProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end
        
        module ClassMethods
          # erm...actually with_mp3, but we'll let it slide ;)
          def with_image(file, &block)
            begin
              logger.warn('file  is ...'+file.inspect)
              binary_data = ::Mp3Info.open(file, &block)
            rescue
              # Log the failure to load the image.  This should match ::Magick::ImageMagickError
              # but that would cause acts_as_attachment to require rmagick.
              logger.debug("Exception working with mp3: #{$!}")
              binary_data = nil
            end
          ensure
            !binary_data.nil?
          end
        end

      protected
        def process_attachment_with_processing
          return unless process_attachment_without_processing
          with_image do |mp3|   
            self.samplerate = mp3.samplerate if mp3.samplerate
            self.bitrate = mp3.bitrate if mp3.bitrate
            self.length = (mp3.length.round if mp3.length) || 0
            self.artist = mp3.tag.artist if mp3.tag.artist
            self.album = mp3.tag.album if mp3.tag.album
            self.title = (mp3.tag.title ? mp3.tag.title.strip : (mp3.tag2.TT2 ? mp3.tag2.TT2.strip : nil))
            #callback_with_args :after_resize, mp3
          end 
        end
      end
    end
  end
end
module Kolossus
  module Kropper
    module ActMethods
      def can_be_cropped
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
        end
      end
      module InstanceMethods
        class InvalidCropRect < StandardError; end
        
        # crops the attached image according to the passed left, top, width, and height params.
        # if resize_to_stencil is true, the image is resized to stencil_w x stencil_h.
        # after cropping and resizing, the resulting image is saved back to disk.
        # any thumbnail image the image may have is automatically updated.
        def crop!( options = {} )
          # setup the default params
          options[:crop_left]   ||= 0
          options[:crop_top]    ||= 0
          options[:crop_width]  ||= 100
          options[:crop_height] ||= 100
          options[:stencil_width]  ||= 100
          options[:stencil_height] ||= 100
          options[:resize_to_stencil] ||= false
          # passed params could be strings, so convert them to ints/booleans
          crop_l = options[:crop_left].to_i
          crop_t = options[:crop_top].to_i
          crop_w = options[:crop_width].to_i
          crop_h = options[:crop_height].to_i
          stencil_w = options[:stencil_width].to_i
          stencil_h = options[:stencil_height].to_i
          resize_to_stencil = false if (options[:resize_to_stencil] == false) || (options[:resize_to_stencil] == "false")
          resize_to_stencil = true if (options[:resize_to_stencil] == true) || (options[:resize_to_stencil] == "true")

          # call the appropriate crop method for the image processor we're using with attachment_fu
          if defined?(Technoweenie::AttachmentFu::Processors::RmagickProcessor) && self.class.include?(Technoweenie::AttachmentFu::Processors::RmagickProcessor)
            crop_with_rmagick! crop_l, crop_t, crop_w, crop_h, stencil_w, stencil_h, resize_to_stencil
          elsif defined?(Technoweenie::AttachmentFu::Processors::ImageScienceProcessor) && self.class.include?(Technoweenie::AttachmentFu::Processors::ImageScienceProcessor)
            crop_with_image_science! crop_l, crop_t, crop_w, crop_h, stencil_w, stencil_h, resize_to_stencil
          else
            raise "You're using an unsupported image processor."
          end
        end

        private

        def crop_with_image_science!(crop_l, crop_t, crop_w, crop_h, stencil_w, stencil_h, resize_to_stencil)
          self.with_image do |img|
            if (crop_w <= 0) || (crop_h <= 0) || (crop_l + crop_w <= 0) || (crop_t + crop_h <= 0) || (crop_l >= img.width) || (crop_t >= img.height)
              # the passed cropping parameters are outside the boundaries of the image, so raise
              raise InvalidCropRect
            end
            self.temp_path = write_to_temp_file(filename)
            img.with_crop(crop_l, crop_t, crop_l + crop_w, crop_t + crop_h ) do |cropped_img|
              if resize_to_stencil
                cropped_img.resize(stencil_w, stencil_h) do |cropped_resized_img|
                  cropped_resized_img.save temp_path
                  callback_with_args :after_resize, cropped_resized_img
                end
              else
                cropped_img.save temp_path
                callback_with_args :after_resize, cropped_img
              end
            end
          end
          save!
        end

        def crop_with_rmagick!(crop_l, crop_t, crop_w, crop_h, stencil_w, stencil_h, resize_to_stencil)
          # create a temporary cropped version of our image
          cropped_img = nil
          self.with_image do |img|
            if (crop_w <= 0) || (crop_h <= 0) || (crop_l + crop_w <= 0) || (crop_t + crop_h <= 0) || (crop_l >= img.base_columns) || (crop_t >= img.base_rows)
              raise InvalidCropRect
            end
            cropped_img = img.crop(crop_l, crop_t, crop_w, crop_h, true )
            cropped_img.resize!(stencil_w, stencil_h) if resize_to_stencil
          end
          # write the cropped image to a temp file, which attachment_fu will use
          # to replace the existing image file (and thumbnail, if any) on save
          self.temp_path = write_to_temp_file(cropped_img.to_blob)
          save!
          callback_with_args :after_resize, cropped_img
        end
      end
    end
  end
end
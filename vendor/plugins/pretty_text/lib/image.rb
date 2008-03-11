require "RMagick" 

module Sudara
  module PrettyText
    class Image
      @@font_path = File.join(RAILS_ROOT, 'fonts')
      @@pretty_text_path = File.join(RAILS_ROOT, 'public', 'images', 'pretty_text')

      cattr_accessor :font_path, :pretty_text_path
      attr_accessor :options, :text, :public_filename

      def initialize(text, options)
        @text = text
        @options = options
        generate_or_find_image!
        self
      end

      def public_filename
         'pretty_text/' + filename
      end
      
      protected
            
      def generate_or_find_image!
        (File.exists?(private_filename) || (@options.delete(:cache) == false)) ? public_filename : generate_image
      end      
      
      def generate_image
        File.rm(private_filename) if File.file?(private_filename)
        # how big is our text going to render with current settings?
        text = draw_text
        text_properties = text.get_multiline_type_metrics(@text)
        options = @options
        final_image = Magick::Image.new(text_properties.width+5, text_properties.height) do
          options.each do |key, value|
            begin
              # set the options on the img +drawer object
               self.send "#{key}=", value if self.respond_to? "#{key}="  
            #rescue 
            end
          end
        end
        # annotate(image, width, height, x-offset, y-offset, draw object)
        text.annotate(final_image, 0,0,0,0, @text)
        final_image.write(private_filename)    
        public_filename
      end
      
      def draw_text
        dummy = Magick::Draw.new
        @options.each do |key, value|
          begin
            # set the options on the img +drawer object
             dummy.send "#{key}=", value if dummy.respond_to? "#{key}="  
          #rescue 
          end
        end
        dummy
      end
      
      def private_filename
        File.join(@@pretty_text_path, filename)
      end

      def filename
        # from mephisto "permalink_for"
        # take the text, replace weirdness with dashes, add the correct file extension
        @image_filename ||= unique_filename.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-') + '.' + @options[:format].downcase
      end    
      
      def unique_filename
        @text[0..15] + '-' + @options[:font].to_s[-10..-5] + '-' + @options[:pointsize].to_s
      end
    end
  end
end
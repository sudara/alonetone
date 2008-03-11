module Sudara

  module PrettyText
    
    @@presets = { :default => {
                  # => :font_family => 'Arial',
                  :pointsize => 20,
                  :gravity => Magick::CenterGravity,
                  :text_antialias => true,
                  :text_align => Magick::CenterAlign,
                  :font_weight => Magick::NormalWeight,
                  :quality => 80,
                  :background_color => 'transparent',
                  :fill => 'black',
                  :format => 'PNG',
                  :stroke => 'transparent',
                  :font => 'Vera.ttf'
    }}
    mattr_reader :presets
    mattr_writer :presets
    # Available options to send pretty_text
    # http://www.simplesystems.org/RMagick/doc/info.html

  
    def pretty_text(text, *args)
      return unless text.is_a?(String) && text.length > 0
      options = {}
      image = '' # dirty little hack due to sudara's stupidity
      benchmark("Rendering pretty_text with RMagick") do
        # args.extract_options! is exciting
        logger.warn "options given to pretty_text: #{options.inspect}"
        
        # allow peeps to define and use stuff like :h1 and :h2 for presets
        if args.first.is_a?(Symbol) && @@presets.has_key?(args.first)
          @preset = args.first
          options = prepare_options(@@presets[:default].merge(@@presets[@preset]))
        else
          @preset = 'pretty_text'
          options = prepare_options(@@presets[:default].merge(args.extract_options!))
        end
        image = Image.new(text, options)        
      end
      begin
        output_image(image, {:alt => text, :class=>@preset.to_s})
      end
    end
   
  
    def output_image(image, options)
      image_tag(image.public_filename, options)
    end
 
    def output_html(image)
      # simulate wanted effect via inline css
      h image.text
    end  
  
    protected
    def prepare_options(options)
      # help the helper by allowing sloppy option passing
      # aka, rmagick names aren't web intuitive, lets also allow css-style names
    
      key_aliases = [
        :pointsize =>       [:size],
        :text_opacity =>    [:opacity],
        :text_align =>      [:align],
        :text_antialias =>  [:antialias],
        :text_undercolor => [:background]
      ]
      
      # TODO: Add default open font / copy the font to /fonts directory on plugin install
      # Add the correct font path
      font = options.delete(:font)
      if font && (valid_font_path = set_font font) then options[:font] = valid_font_path end        
      logger.warn "pretty text options after processing: #{options.inspect}"      
      
      options
    end
    
    def set_font(font)
      unless font.empty?
        path_to_font = ""
        # priority to the path that the user can set
        [File.join(RAILS_ROOT, 'vendor', 'plugins', 'pretty_text', 'fonts'), Image.font_path].each do |path|
          path_to_font = File.join(path, font) if File.exist?(File.join(path, font))
        end
        path_to_font.empty? ? nil : path_to_font
      end
    end
    
  end
end
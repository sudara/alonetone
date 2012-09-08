require 'mp3info'
require "paperclip"
module Paperclip
  
  class Mp3PaperclipProcessor
    def initialize(file, options={}, attachment=nil)
      super
      @instance = @attachment.instance
    end
    
    # this is the required method for the paperclip processor
    def make
      begin
        # rather than create another file, bust open the current one
        binary_data = ::Mp3Info.open(file) do 
          write_meta_data_to_model(self)
        end
      rescue
        # if mp3info can't open it, don't let this attachment succeed
        file = nil 
      end
      file
    end
    
    def write_metadata_to_model(mp3)
      instance = @attachment.instance
      %w(samplerate bitrate length artist album).each do |simple_attribute|
        # copy the data out of the mp3 
        if mp3.respond_to?(:simple_attribute) and @instance.respond_to?(:simple_attribute)
          @instance.send(:simple_attribute, mp3.send(:simple_attribute))
        end
        # title is a bit more complicated depending on tag type
        @instance.title = (mp3.tag.title ? mp3.tag.title.strip : (mp3.tag2.TT2 ? mp3.tag2.TT2.strip : nil)) if @instance.respond_to? :title
      end
    end
  end
end
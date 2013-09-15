# -*- encoding : utf-8 -*-
require 'mp3info'
require "paperclip"
module Paperclip
  
  class Mp3PaperclipProcessor < Processor
    
    # this is the required method for the paperclip processor
    def make
      
      #begin
        # rather than create another file, bust open the current one
        binary_data = ::Mp3Info.open(@file.path) do |mp3|
          write_meta_data_to_model(mp3)
        end
      #rescue
        # if mp3info can't open it, don't let this attachment succeed
        #@file = nil 
        #end
      @file
    end
    
    def write_meta_data_to_model(mp3)
      %w(samplerate bitrate length artist album).each do |simple_attribute|
        # copy the data out of the mp3 
        if @attachment.instance.respond_to?("#{simple_attribute}=") and mp3.respond_to?(simple_attribute)
          @attachment.instance.send("#{simple_attribute}=",mp3.send(simple_attribute))
        end
        # title is a bit more complicated depending on tag type
         @attachment.instance.title = set_title(mp3)
         @attachment.instance.generate_permalink!
      end
    end
    
    def set_title(mp3)
      if mp3.tag.title.present?
        mp3.tag.title.strip
      elsif mp3.tag2.TT2.present?
        mp3.tag2.TT2.strip 
      else
        nil
      end
    end
  end
end

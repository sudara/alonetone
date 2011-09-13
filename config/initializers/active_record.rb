# From altered beast

class ActiveRecord::Base
  @@white_list_sanitizer = HTML::WhiteListSanitizer.new
  class << self
    attr_accessor :formatted_attributes
  end
 
  cattr_reader :white_list_sanitizer
 
  def self.formats_attributes(*attributes)
    (self.formatted_attributes ||= []).push *attributes
    before_save :format_attributes
    send :include, HtmlFormatting, ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper
  end

end


# Default error message sucks
ActiveRecord::Errors.default_error_messages[:inclusion] = "wasn't a real mp3 or zip file of mp3s. Can you double check that it is a .mp3 and not another kind of file? If you are sure, email it to support@alonetone.com so he can help you get it on alonetone. Apologies for ze troubles."
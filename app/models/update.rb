require 'bluecloth'
class Update < ActiveRecord::Base
  
  formats_attributes :content
  
  
  def print
    self.content_html || BlueCloth::new(self.content).to_html
  end
  
end

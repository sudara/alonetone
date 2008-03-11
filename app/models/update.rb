require 'bluecloth'
class Update < ActiveRecord::Base
  
  
  def print
    BlueCloth::new(self.content).to_html
  end
  
end

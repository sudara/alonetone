require 'hpricot'
class BlueCloth
  
  def to_html_with_friendly_breaks(lite=false)
    parsed = to_html_without_friendly_breaks(lite)
    return BlueCloth.to_user_friendly_html(parsed)
  end
  
  # adapted from http://www.depixelate.com/2006/10/25/markdown-with-hard-breaks 
  def self.to_user_friendly_html(html)
    returning html do 
      Hpricot(html).search("//p").each do |p|
        html.sub!(p.to_s, p.to_s.gsub(%r{\n+}, "\n<br/>\n"))
      end
    end
  end
  
  alias_method_chain :to_html, :friendly_breaks

end
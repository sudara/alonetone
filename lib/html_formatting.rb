module HtmlFormatting
  protected
  
  def format_attributes
    self.class.formatted_attributes.each do |attr|
      raw    = read_attribute attr
      return unless raw && !raw.empty?
      result = BlueCloth::new(raw).to_html
      # let admins post javascript and whatever they like in bluecloth while restricting guests/users
      unless !self.respond_to?(:user) || (self.user && self.user.admin?)
        result = auto_link(result,:all) { |text| truncate(text, 35) } 
        result = white_list_sanitizer.sanitize(result)
      end
      write_attribute "#{attr}_html", result
    end
  end
end
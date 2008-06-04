module HtmlFormatting
  protected
  
  def format_attributes
    self.class.formatted_attributes.each do |attr|
      raw    = read_attribute attr
      markdowned = BlueCloth::new(raw).to_html
      autolinked = auto_link(markdowned,:all, :target => '_blank') { |text| truncate(text, 30) }
      write_attribute "#{attr}_html", white_list_sanitizer.sanitize(autolinked)
    end
  end
end
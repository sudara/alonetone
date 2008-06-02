module HtmlFormatting
  protected
  
  def format_attributes
    self.class.formatted_attributes.each do |attr|
      raw    = read_attribute attr
      linked = auto_link(raw) { |text| truncate(text, 50) }
      markdowned = BlueCloth::new(linked).to_html
      write_attribute "#{attr}_html", white_list_sanitizer.sanitize(markdowned)
    end
  end
end
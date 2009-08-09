xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.feed "xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom' do
  xml.title       "alonetone blog"
  xml.id          "tag:#{request.host},#{Time.now.utc.year}:alonetone"
  xml.link "rel" => "self",      "type" => "application/atom+xml", "href" => url_for(:only_path => false)
  xml.link "rel" => "alternate", "type" => "text/html",
    "href" => 'http://alonetone.com'

  xml.updated @updates.first.updated_at.xmlschema 
  @updates.each do |update|
    xml.entry 'xml:base' => 'http://alonetone.com' do
      xml.author do
        xml.name User.first.name
      end
      xml.id        "tag:http://alonetone.com,#{update.created_at.to_date.to_s :db}:#{update.id}"
      xml.published update.created_at.xmlschema
      xml.updated   update.updated_at.xmlschema
      xml.category "term" => 'news and updates'
      xml.link "rel" => "alternate", "type" => "text/html", 
        "href" => blog_path(update)
      xml.title     strip_tags(update.title)
      unless update.content_html.blank?
        xml << %{<content type="html">
                #{sanitize_feed_content(([update.content_html].compact * "\n"))}
              </content>}
      end
    end
  end
end
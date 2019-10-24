# https://www.lugolabs.com/articles/render-markdown-views-with-redcarpet-and-pygment-in-rails
class MarkdownHandler
  def call(template, source)
    "#{render(source).inspect}.html_safe;"
  end

  def render(text)
    key = cache_key(text)
    Rails.cache.fetch key do
      add_anchors(markdown(text)).html_safe
    end
  end

  private
  def cache_key(text)
    Digest::MD5.hexdigest("#{text}v2")
  end

  def markdown(text)
    CommonMarker.render_doc(text, :SMART).to_html(:HARDBREAKS, [:autolink, :strikethrough])
  end

  # Rather than add a pipeline / library just for header anchors, we steal from html-pipeline
  # https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb
  def add_anchors(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css('h1, h2, h3, h4, h5, h6').each do |node|
      text = node.text
      id = ActiveSupport::Inflector.parameterize(text)
      if header_content = node.children.first
        header_content.add_previous_sibling(%(<a id="#{id}" class="anchor" href="##{id}" aria-hidden="true"></a>))
      end
    end
    doc.to_html
  end
end


ActionView::Template.register_template_handler(:md, MarkdownHandler.new)
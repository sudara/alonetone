# https://www.lugolabs.com/articles/render-markdown-views-with-redcarpet-and-pygment-in-rails
class MarkdownHandler
  def call(template, source)
    "#{render(source).inspect}.html_safe;"
  end

  def render(text)
    key = cache_key(text)
    Rails.cache.fetch key do
      markdown(text).html_safe
    end
  end

  private
  def cache_key(text)
    Digest::MD5.hexdigest(text)
  end

  def markdown(text)
    CommonMarker.render_doc(text, :SMART).to_html(:HARDBREAKS, [:autolink, :strikethrough])
  end
end


ActionView::Template.register_template_handler(:md, MarkdownHandler.new)
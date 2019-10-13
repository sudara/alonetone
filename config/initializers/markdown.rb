  # https://www.lugolabs.com/articles/render-markdown-views-with-redcarpet-and-pygment-in-rails
class MarkdownHandler
  def call(template, source)
    "#{render(template.source).inspect}.html_safe;"
  end

  def render(text)
    key = cache_key(text)
    Rails.cache.fetch key do
      markdown.render(text).html_safe
    end
  end

  private
  def cache_key(text)
    Digest::MD5.hexdigest(text)
  end

  def markdown
    #     smarty = Redcarpet::Render::SmartyPants.render(markdown.render(template.source)).html_safe
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, autolink: true, space_after_headers: true)
  end
end


ActionView::Template.register_template_handler(:md, MarkdownHandler.new)
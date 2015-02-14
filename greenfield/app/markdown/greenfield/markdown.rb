module Greenfield
  class Markdown < Redcarpet::Render::HTML
    def block_code(code, language)
      if language == 'embed'
        asset = Greenfield::AttachedAsset.find(code.to_i)
        Greenfield::ApplicationController.helpers.view_paths = ['greenfield/app/views']
        Greenfield::ApplicationController.helpers.player(asset)
      else
        %(<pre><code class="#{language}">#{CGI.escapeHTML(code)}</code></pre>)
      end
    end
    
    def header(text, level)
      level += 2
      "<h#{level}>#{text}</h#{level}>"
    end

    def self.transform_embeds(post, text)
      text.gsub(/``(\d+)``/) do |m|
        asset_num = m.match(/\d+/)[0].to_i
        asset_id = post.attached_assets[asset_num-1].id
        "\n\n```embed\n#{asset_id}\n```"
      end
    end

    def self.invalid_embeds(post)
      (post.body || '').scan(/``(\d+)``/).flatten.map(&:to_i).select do |i|
        i.zero? || i > post.attached_assets.size
      end
    end

    def self.render(text)
      renderer = Redcarpet::Markdown.new(new(:hard_wrap => true),
                      :autolink => true, :no_intraemphasis => true,
                      :fenced_code_blocks => true)
      Redcarpet::Render::SmartyPants.render(renderer.render(text)).html_safe
    end

    def self.render_with_embeds(post, text)
      render(text = transform_embeds(post, text))
    end
  end
end

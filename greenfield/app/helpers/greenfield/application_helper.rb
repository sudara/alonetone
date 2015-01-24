module Greenfield
  module ApplicationHelper
    def emojify(content)
      content.gsub(/:([a-z0-9\+\-_]+):/) do |match|
        if Emoji.names.include?($1)
          '<img alt="' + $1 + '" height="20" src="' + asset_path("images/emoji/#{$1}.png") + '" style="vertical-align:middle" width="20" />'
        else
          match
        end
      end.html_safe
    end

    def markdown(text)
      return "" unless text
      text = emojify(text)
      @@renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(:hard_wrap => true),
                                             :autolink => true, :no_intraemphasis => true) 
      Redcarpet::Render::SmartyPants.render(@@renderer.render(text)).html_safe
    end
  end
end

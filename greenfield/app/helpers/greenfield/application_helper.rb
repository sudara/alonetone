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

    def markdown(text, post: nil)
      return "" unless text
      text = emojify(text)
      if post
        Greenfield::Markdown.render_with_embeds(post, text)
      else
        Greenfield::Markdown.render(text)
      end
    end

    def player(asset)
      if asset.is_a?(Greenfield::AttachedAsset)
        link_url = Greenfield::Engine.routes.url_helpers.
                     user_post_attached_asset_path(asset.user, asset.alonetone_asset, 
                                                   asset, :format => :mp3)
      else
        link_url = Rails.application.routes.url_helpers.
                     user_track_path(asset.user, asset, :format => :mp3)
      end

      waveform = asset.waveform.join(', ')

      content_tag(:div, :class => 'player') do
        [
          content_tag(:i, :class => "fa fa-play fa-3x play-button play-control") do
            link_to '', link_url
          end,

          content_tag(:div, :class => 'waveform', :'data-waveform' => waveform) do
            content_tag(:div, :class => 'seekbar'){ }
          end,

          content_tag(:div, :class => 'time') do
            current = content_tag(:span, '0:00', :class => 'index')
            "#{current} of #{asset.length}".html_safe
          end,
          
          content_tag(:div, :class => 'download-button') do
            link_to '', link_url
          end
          
        ].join.html_safe
      end
    end

    def mp3_upload(field_name, url, init=[])
      file_field = file_field_tag(field_name, :'data-url' => url,
                                  :class => 'mp3_upload', :multiple => true)

      init = init.map(&:mp3).map do |mp3|
        name = content_tag(:div, mp3.original_filename, :class => 'name')
        size = content_tag(:div, number_to_human_size(mp3.size), :class => 'status')
        content_tag(:div, name+size, :class => 'file')
      end.join.html_safe
      results = content_tag(:div, init, :class => 'upload-results')

      content_tag(:div, results + file_field)
    end
  end
end

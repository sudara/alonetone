module AssetsHelper

  def radio_option(path,name, default = false,disabled_if_not_logged_in=false)
    classes = "radio_channel #{params[:source] == path ? 'selected' : ''} #{!logged_in? && disabled_if_not_logged_in ? 'disabled' : ''}"
      content_tag :li, (radio_button_tag('source', path, (params[:source] == path || (!params[:source]) && default), 
        :disabled => !logged_in? && disabled_if_not_logged_in) + content_tag(:span, (disabled_if_not_logged_in ? "#{name} #{login_link}" : name).html_safe, :class=> 'channel_name')),
         :class => classes
  end
end

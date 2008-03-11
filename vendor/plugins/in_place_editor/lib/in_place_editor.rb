module ActionView::Helpers::JavaScriptMacrosHelper
  def in_place_editor(field_id, options = {})
    options.reverse_merge! :quoted => {}

    function =  "new Ajax.InPlaceEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options.delete(:url))}'"

    # translate old keys to new ones 
    {:ok_text => :save_text, :ajax_options => :option, :eval_scripts => :script}.each do |new_key, old_key|
      option = options.delete(old_key)
      options[new_key] = option if option
    end

    js_options = {}

    # old custom options
    option = options.delete(:load_text_url)
    js_options['loadTextURL'] = "'#{url_for(option)}'" if option
    option = options.delete(:with)
    js_options['callback']   = "function(form) { return #{option} }" if option

    # old quoted options, plus new quoted options
    options.merge! options[:quoted]
    ([:cancel_text, :ok_text, :loading_text, :saving_text, :external_control, :click_to_edit_text] | options[:quoted].keys).each do |key|
      option = options.delete(key)
      js_options[key.to_s.camelize(:lower)] = "'#{option}'" if option
    end

    options.delete :quoted

    # add the rest of the options (unquoted... as is)
    options.each do |key, value|
      option = options.delete(key)
      js_options[key.to_s.camelize(:lower)] = option if option
    end

    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?

    function << ')'

    javascript_tag(function)
  end
end

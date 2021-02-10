# frozen_string_literal: true

class AdminFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::FormTagHelper

  attr_accessor :output_buffer

  def field(attribute, options = {}, &block)
    content = @template.capture(&block) if block_given?
    options[:class] = options.key?(:class) ? Array(options[:class]) : []
    options[:class] << 'field'
    options[:class] << 'invalid' if @object.errors.include?(attribute)
    tag.div(**options) do
      concat(content) if content.present?
    end
  end

  def label_with_error(name)
    if @object.errors.messages[name].present?
      label(
        name, [
          @object.class.human_attribute_name(name),
          @object.errors.messages[name].to_sentence
        ].join(' ')
      )
    else
      label(name)
    end
  end
end

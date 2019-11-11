# frozen_string_literal: true

require 'slug'

# Provides functionality to automatically set and update slugs for an Active
# Record model.
module Slugs
  extend ActiveSupport::Concern

  included do
    # Keeps a mapping between a slug column and its configuration.
    class_attribute :slugs, default: {}

    before_save :make_slugs_unique
  end

  private

  # Increments slugs when they changed and conflict with another slug.
  def make_slugs_unique
    slugs.each do |column, (_, scope_column)|
      next unless changes.key?(column.to_s)

      current_slug = send(column)
      scope_value = scope_column ? send(scope_column) : nil
      while self.class.slug_taken?(column, current_slug, scope_column, scope_value)
        current_slug = Slug.increment(current_slug)
        send("#{column}=", current_slug)
      end
    end
  end

  class_methods do
    # Configures a column so its value is set based on the from_attribute. The slug value will
    # be made unique within the defined scope. If the from_attribute does not have a value it
    # will get the default value.
    def has_slug(column, from_attribute:, scope: nil, default: nil)
      slugs[column] = [from_attribute, scope]

      attribute(column, default: default) if default

      define_method("#{from_attribute}=") do |value|
        result = super(value)
        if changes.key?(from_attribute.to_s)
          send("#{column}=", Slug.generate(result).presence || default)
        end
        result
      end
    end

    # Returns true when another record with the specified column value exists in the given scope
    # with the scope value.
    #
    #   Author.slug_taken?(:slug, 'bob-writer', nil, nil)
    #   Book.slug_taken?(:slug, 'wonderful-life', :author_id, 54)
    def slug_taken?(column, value, scope_column, scope_value)
      conditions = { column => value }
      conditions[scope_column] = scope_value if scope_column
      exists?(conditions)
    end
  end
end

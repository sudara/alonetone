require 'iconv'
require 'digest/sha1'
module PermalinkFu
  class << self
    attr_accessor :translation_to
    attr_accessor :translation_from
    
    # This method does the actual permalink escaping.
    def escape(string)
      result = ((translation_to && translation_from) ? Iconv.iconv(translation_to, translation_from, string) : string).to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
      result.downcase!
      result.size.zero? ? random_permalink(string) : result
    rescue
      random_permalink(string)
    end
    
    def random_permalink(seed = nil)
      Digest::SHA1.hexdigest("#{seed}#{Time.now.to_s.split(//).sort_by {rand}}")
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
    class << base
      attr_accessor :permalink_options
      attr_accessor :permalink_attributes
      attr_accessor :permalink_field
    end
  end
  
  module ClassMethods
    # Specifies the given field(s) as a permalink, meaning it is passed through PermalinkFu.escape and set to the permalink_field.  This
    # is done
    #
    #   class Foo < ActiveRecord::Base
    #     # stores permalink form of #title to the #permalink attribute
    #     has_permalink :title
    #   
    #     # stores a permalink form of "#{category}-#{title}" to the #permalink attribute
    #   
    #     has_permalink [:category, :title]
    #   
    #     # stores permalink form of #title to the #category_permalink attribute
    #     has_permalink [:category, :title], :category_permalink
    #
    #     # add a scope
    #     has_permalink :title, :scope => :blog_id
    #
    #     # add a scope and specify the permalink field name
    #     has_permalink :title, :slug, :scope => :blog_id
    #   end
    #
    def has_permalink(attr_names = [], permalink_field = nil, options = {})
      if permalink_field.is_a?(Hash)
        options = permalink_field
        permalink_field = nil
      end
      self.permalink_attributes = Array(attr_names)
      self.permalink_field      = permalink_field || :permalink
      self.permalink_options    = options
    end
  end
  
protected
  def create_unique_permalink
    send("#{self.class.permalink_field}=", create_permalink_for(self.class.permalink_attributes))
    base       = send(self.class.permalink_field)
    counter    = 1
    # oh how i wish i could use a hash for conditions
    conditions = ["#{self.class.permalink_field} = ?", send(self.class.permalink_field)]
    unless new_record?
      conditions.first << " and id != ?"
      conditions       << id
    end
    if self.class.permalink_options[:scope]
      conditions.first << " and #{self.class.permalink_options[:scope]} = ?"
      conditions       << send(self.class.permalink_options[:scope])
    end
    while self.class.count(:all, :conditions => conditions) > 0
      conditions[1] = "#{base}-#{counter += 1}"
      send("#{self.class.permalink_field}=", conditions[1])
    end
  end

  def create_permalink_for(attr_names)
    attr_names.collect do |attr_name| 
      PermalinkFu.escape(send(attr_name).to_s)
    end.join('-')
  end
end

PermalinkFu.translation_to   = 'ascii//ignore//translit'
PermalinkFu.translation_from = 'utf-8'
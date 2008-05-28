# Goodies to make development more enjoyable


class Object

  # The classic shortcut from  http://ozmm.org/
  #
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  #
  def try(method)
    send method if respond_to? method
  end
  
  # With conditional and possibly empty love from Sudara
  #
  #   if params.present? :search
  # vs  
  #   if params[:search] && !params[:search].empty?
  #
  #
  #   if params.present? :search, :filter   
  # vs
  #   if (params[:search] && !params[:search].empty?) && (params[:filter] && !params[:filter].empty?)
  #
  #
  #   <% if @person.present? :name %>
  # vs
  #   <% if @person.name && !@person.name.empty? %>
  #
  #
  # Bonus points for:
  #   present? @query, @results
  #
  def present?(*methods_variables_or_attributes)
    methods_variables_or_attributes.detect do |monkey|
      if (monkey.is_a? Symbol) 
        result = try(monkey)
        result && !result.empty?
      elsif self.is_a? Hash  # hashes with string keys
        result = self[monkey]   
        result && !result.empty?
      else # allow plain jane variables to be tested 
        monkey && !monkey.empty?
      end
    end
  end
end

class Array
  # If +number+ is greater than the size of the array, the method
  # will simply return the array itself sorted randomly
  def randomly_pick(number)
    sort_by{ rand }.slice(0...number)
  end
end
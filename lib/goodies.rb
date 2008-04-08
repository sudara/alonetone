# Goodies to make development more enjoyable


class Object
  ## http://ozmm.org/
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    method = method.to_sym
    send method if respond_to? method
  end
  
  # my version of the above for conditional chunks
  # turn this:
  #   params[:bloo][:blah] && !params[:bloo][:blah].empty?
  # into this:
  #   params[:booo].present?(:blah)
  #
  # and this:
  #   <% if @person.name && !@person.name.empty? %>
  # into this:
  #   <% if @person.present?(:name)
  def present?(attribute)
    attribute = attribute.to_sym
    if respond_to? attribute
      result = send attribute
      result.empty? ? false : result
    end
    false
  end
  
end
# Goodies to make development more enjoyable


class Object
  #
  # The classic shortcut from  http://ozmm.org/
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  #
  def try(method)
    send method if respond_to? method
  end
  
  #
  # With conditional and empty love by Sudara
  #   if params[:booo].present?(:blah)
  # vs  
  #   if params[:bloo][:blah] && !params[:bloo][:blah].empty?
  #
  #
  #   <% if @person.name && !@person.name.empty? %>
  # vs
  #   <% if @person.present?(:name)
  #
  def present?(method_or_attribute)
    result = try(method_or_attribute.to_sym)
    return result if (result && !result.empty?) 
    false
  end
  
  #
  # @user.email = ""
  # @user.email             => ""
  # @user.try(:email)       => ""
  # @user.present?(:email)  => ""
  # @user.nonempty(:email)  => nil
  
  def nonempty(method_or_attribute)
    result = return try(method_or_attribute.to_sym)
    return ((result && !result.empty?) ? result : nil)
  end
  
end
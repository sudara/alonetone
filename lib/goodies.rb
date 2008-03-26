# Goodies to make development more enjoyable


class Object
  ## http://ozmm.org/
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
  
end
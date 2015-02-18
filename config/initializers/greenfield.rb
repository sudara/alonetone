
if ENV['GREENFIELD']
  Alonetone.define_singleton_method(:greenfield?){ true }
else
  Alonetone.define_singleton_method(:greenfield?){ false }
end

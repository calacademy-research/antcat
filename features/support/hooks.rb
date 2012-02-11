# coding: UTF-8

Before do
  Family.delete_all
  Factory :family, protonym: nil
end

After {Sunspot.remove_all!}

#at_exit do
  #Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session) if ENV['DRB'] != 'true'
#end




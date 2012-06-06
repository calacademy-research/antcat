class Name < ActiveRecord::Base

  def self.import name
    Name.create! name_object_name: name
  end

end

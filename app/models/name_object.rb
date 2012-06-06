class NameObject < ActiveRecord::Base

  def self.import name
    NameObject.create! name_object_name: name
  end

end

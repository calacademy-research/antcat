class Name < ActiveRecord::Base

  def self.import name
    Name.create! name: name
  end

end

class Name < ActiveRecord::Base

  def self.import data
    Name.create! name: data[:name]
  end

end

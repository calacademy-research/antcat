class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import name, data = {}
    name_object = find_by_name name
    return name_object if name_object

    subclass = case
    when data[:genus_name] then GenusName
    else Name
    end
    subclass.create! name: name
  end

end

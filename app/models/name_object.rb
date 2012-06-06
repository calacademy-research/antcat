class NameObject < ActiveRecord::Base

  validates :name_object_name, presence: true

  def self.import name
    NameObject.create! name_object_name: name
  end

end

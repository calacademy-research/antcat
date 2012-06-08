# coding: UTF-8
module Nameable

  def self.included includer
    includer.belongs_to  :name_object, class_name: 'Name'
    includer.validates   :name_object, presence: true
  end

  def name
    return '' if new_record? and not name_object
    name_object.name
  end

end

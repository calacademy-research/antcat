# coding: UTF-8
module Nameable

  def self.included includer
    includer.belongs_to  :name
    includer.validates   :name, presence: true
  end

end

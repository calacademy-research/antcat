# coding: UTF-8
class ReferenceLocation < ActiveRecord::Base
  belongs_to :reference

  def self.import reference_location
    reference = Reference.find_by_bolton_author_year reference_location
    create! :reference => reference, :pages => reference_location[:pages]
  end

end

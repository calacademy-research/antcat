# coding: UTF-8
class Citation < ActiveRecord::Base
  belongs_to :reference

  def self.import data
    reference = Reference.find_by_bolton_key data[:author_names], data[:year]
    create! :reference => reference, :pages => data[:pages]
  end

end

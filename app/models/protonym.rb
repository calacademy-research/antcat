# coding: UTF-8
class Protonym < ActiveRecord::Base
  belongs_to :authorship, :class_name => 'ReferenceLocation'

  def self.import name, authorship
    transaction do
      authorship = ReferenceLocation.import authorship
      create! :name => name, :authorship => authorship
    end
  end
end

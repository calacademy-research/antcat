# coding: UTF-8
class Protonym < ActiveRecord::Base
  belongs_to :authorship, :class_name => 'Citation'

  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first
      create! :name => data[:name], :authorship => authorship
    end
  end
end

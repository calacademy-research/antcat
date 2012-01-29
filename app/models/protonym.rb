# coding: UTF-8
class Protonym < ActiveRecord::Base
  belongs_to :authorship, :class_name => 'Citation'

  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first

      case 
      when data[:family_or_subfamily_name]
        name = data[:family_or_subfamily_name]
        rank = 'family_or_subfamily'
      when data[:genus_name]
        name = data[:genus_name]
        rank = 'genus'
      when data[:subgenus_name]
        name = data[:subgenus_name]
        rank = 'subgenus'
      when data[:tribe_name]
        name = data[:tribe_name]
        rank = 'tribe'
      end

      create! name: name, rank: rank, sic: data[:sic], fossil: data[:fossil], authorship: authorship

    end
  end
end

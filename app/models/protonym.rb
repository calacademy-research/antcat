# coding: UTF-8
class Protonym < ActiveRecord::Base
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy

  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first if data[:authorship]

      case 
      when data[:family_or_subfamily_name]
        name = data[:family_or_subfamily_name]
        rank = 'family_or_subfamily'
      when data[:species_epithet]
        name = data[:genus_name]
        name << ' (' << data[:subgenus_epithet] << ') ' if data[:subgenus_epithet]
        name << ' ' + data[:species_epithet]
        if data[:subspecies]
          subspecies = data[:subspecies].first
          name << ' ' + subspecies[:type] << ' ' << subspecies[:subspecies_epithet]
        end
        rank = 'species'
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

      create! name: name,
              rank: rank,
              sic: data[:sic],
              fossil: data[:fossil],
              authorship: authorship,
              locality: data[:locality]

    end
  end
end

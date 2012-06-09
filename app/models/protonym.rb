# coding: UTF-8
class Protonym < ActiveRecord::Base
  include Nameable
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy

  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first if data[:authorship]

      case 
      when data[:species_epithet]
        name = data[:genus_name].dup
        name << ' (' << data[:subgenus_epithet] << ') ' if data[:subgenus_epithet]
        name << ' ' + data[:species_epithet]
        if data[:subspecies]
          subspecies = data[:subspecies].first
          name << ' ' + subspecies[:type] if subspecies[:type]
          name << ' ' << subspecies[:subspecies_epithet]
        end
        rank = 'species'
      when data[:subgenus_name]
        rank = 'subgenus'
      when data[:genus_name]
        rank = 'genus'
      when data[:subtribe_name]
        rank = 'subtribe'
      when data[:tribe_name]
        rank = 'tribe'
      when data[:family_or_subfamily_name]
        rank = 'family_or_subfamily'
      end

      create! name_object:  Name.import(data),
              rank:         rank,
              sic:          data[:sic],
              fossil:       data[:fossil],
              authorship:   authorship,
              locality:     data[:locality]

    end
  end
end

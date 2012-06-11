# coding: UTF-8
class Protonym < ActiveRecord::Base
  include Nameable
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy

  def name
    return '' if new_record? and not name_object
    name_object.name
  end

  def rank
    return '' if new_record? and not name_object
    name_object.rank
  end

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
      end

      create! name_object:  Name.import(data),
              sic:          data[:sic],
              fossil:       data[:fossil],
              authorship:   authorship,
              locality:     data[:locality]

    end
  end

end

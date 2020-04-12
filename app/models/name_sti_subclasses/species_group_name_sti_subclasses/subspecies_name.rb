# frozen_string_literal: true

class SubspeciesName < SpeciesGroupName
  def subspecies_epithets
    name_parts[2..-1].join(' ')
  end

  def short_name
    [genus_epithet[0] + '.', species_epithet[0] + '.', subspecies_epithets].join(' ')
  end
end

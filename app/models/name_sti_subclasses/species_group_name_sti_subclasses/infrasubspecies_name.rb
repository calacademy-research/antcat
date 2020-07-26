# frozen_string_literal: true

class InfrasubspeciesName < SpeciesGroupName
  def subspecies_epithet
    name_parts[2]
  end

  def short_name
    [
      genus_epithet[0] + '.',
      species_epithet[0] + '.',
      subspecies_epithet[0] + '.',
      epithet
    ].join(' ')
  end
end

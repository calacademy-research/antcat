# frozen_string_literal: true

# The name of an infrasubspecies, with its subspecies epithet and short form.
class InfrasubspeciesName < SpeciesGroupName
  def subspecies_epithet
    cleaned_name_parts[2]
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

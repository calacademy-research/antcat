# frozen_string_literal: true

# A name of species-group rank (species, subspecies, infrasubspecies), with its genus and species epithets; a kind
# of `Name`.
class SpeciesGroupName < Name
  def genus_epithet
    cleaned_name_parts[0]
  end

  def species_epithet
    cleaned_name_parts[1]
  end
end

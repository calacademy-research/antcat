# frozen_string_literal: true

class SpeciesGroupName < Name
  def genus_epithet
    name_parts[0]
  end

  # TODO: This does not work for protonyms with a subgenus in the name (but that's OK for now since we only use it for taxa.)
  def species_epithet
    name_parts[1]
  end
end

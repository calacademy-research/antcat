# frozen_string_literal: true

class InfrasubspeciesName < SpeciesGroupName
  def subspecies_epithet
    name_parts[2]
  end
end

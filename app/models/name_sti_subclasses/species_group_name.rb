# frozen_string_literal: true

class SpeciesGroupName < Name
  def genus_epithet
    cleaned_name_parts[0]
  end

  def species_epithet
    cleaned_name_parts[1]
  end
end

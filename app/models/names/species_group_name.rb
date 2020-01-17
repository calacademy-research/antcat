# NOTE: This is the `Name` type used for `SpeciesGroupTaxon` records, not to
# be confused with "species group" or "species-group name" as used in taxonomy.

class SpeciesGroupName < Name
  def genus_epithet
    name_parts[0]
  end

  # TODO: This does not work for protonyms with a subgenus in the name (but that's OK for now since we only use it for taxa.)
  def species_epithet
    name_parts[1]
  end

  private

    def change name_string
      existing_names = Name.joins(:taxa).where.not(id: id).where(name: name_string)
      raise Taxa::TaxonExists, existing_names if existing_names.any?
      self.name = name_string
    end
end

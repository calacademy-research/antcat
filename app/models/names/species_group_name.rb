class SpeciesGroupName < Name
  def genus_epithet
    name_parts[0]
  end

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

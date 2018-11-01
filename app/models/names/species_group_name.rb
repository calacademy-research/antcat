class SpeciesGroupName < Name
  def genus_epithet
    words[0]
  end

  def species_epithet
    words[1]
  end

  def dagger_html
    italicize super
  end

  private

    def change name_string
      existing_names = Name.where.not(id: id).where(name: name_string)
      raise Taxon::TaxonExists if existing_names.any? { |name| !name.what_links_here.empty? }
      update! name: name_string, name_html: italicize(name_string)
    end
end

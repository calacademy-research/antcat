class SubspeciesName < SpeciesGroupName
  validates :epithets, presence: true
  validate :ensure_epithets_in_name

  def subspecies_epithets
    name_parts[2..-1].join ' '
  end

  def change_parent species_name
    name_string = [species_name.genus_epithet, species_name.species_epithet, subspecies_epithets].join ' '
    change name_string
    update! epithets: species_name.epithet + ' ' + subspecies_epithets
  end

  private

    def ensure_epithets_in_name
      return if name.blank? || epithets.blank?
      return if name.include?(epithets)

      errors.add :epithets, "must occur in the full name"
      throw :abort
    end
end

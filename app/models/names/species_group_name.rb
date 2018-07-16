class SpeciesGroupName < Name
  # TODO see if we can DRY this or the `#change_parent`s in `SpeciesName and `SubspeciesName`.
  def self.name_for_new_comb old_comb, new_comb_parent
    raise "uncombinable ranks" unless valid_rank_combination? old_comb, new_comb_parent

    name_parts = [new_comb_parent.name.genus_epithet]
    case new_comb_parent
    when Species then name_parts << new_comb_parent.name.species_epithet <<
                                    old_comb.name.epithet
    when Genus   then name_parts << old_comb.name.species_epithet
    else                            raise "we should never get here"
    end

    Names::CreateNameFromString[name_parts.join(' ')]
  end

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

    def self.valid_rank_combination? old_comb, new_comb_parent
      old_comb.is_a?(Species) && new_comb_parent.is_a?(Genus) ||
        old_comb.is_a?(Subspecies) && new_comb_parent.is_a?(Species)
    end
    private_class_method :valid_rank_combination?
end

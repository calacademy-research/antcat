# Note: This is the superclass of Species and Subspecies, not to
# be confused with "species group" as used in taxonomy.

class SpeciesGroupTaxon < Taxon
  attr_accessible :genus, :subfamily, :subfamily_id, :type_name_id

  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true

  before_create :set_subfamily

  def recombination?
    genus_epithet = name.genus_epithet
    protonym_genus_epithet = protonym.name.genus_epithet

    genus_epithet != protonym_genus_epithet
  end

  def inherit_attributes_for_new_combination old_comb, new_comb_parent
    self.name = name_for_new_comb old_comb, new_comb_parent

    attributes = [:protonym, :verbatim_type_locality, :biogeographic_region,
      :type_specimen_repository, :type_specimen_code, :type_specimen_url]

    attributes.each do |attribute|
      old_comb_value = old_comb.send attribute
      self.send "#{attribute}=", old_comb_value
    end
  end

  private
    def set_subfamily
      self.subfamily = genus.subfamily if genus && genus.subfamily
    end

    def name_for_new_comb old_comb, new_comb_parent
      raise unless valid_rank_combination? old_comb, new_comb_parent

      name_parts = [new_comb_parent.name.genus_epithet]
      case new_comb_parent
      when Species then name_parts << new_comb_parent.name.species_epithet <<
                                      old_comb.name.epithet
      when Genus   then name_parts << old_comb.name.species_epithet
      else                            raise "we should never get here"
      end

      Name.parse name_parts.join(' ')
    end

    # TODO repurpose for `.inherit_attributes_for_new_combination`.
    def valid_rank_combination? old_comb, new_comb_parent
      old_comb.is_a?(Species) && new_comb_parent.is_a?(Genus) ||
        old_comb.is_a?(Subspecies) && new_comb_parent.is_a?(Species)
    end
end

# Note: This is the superclass of Species and Subspecies, not
# be confused with "species group" as used in taxonomy.

class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  validates :genus, presence: true
  belongs_to :subgenus
  before_create :set_subfamily
  attr_accessible :genus, :subfamily, :subfamily_id, :type_name_id

  def recombination?
    genus_epithet = name.genus_epithet
    protonym_genus_epithet = protonym.name.genus_epithet
    genus_epithet != protonym_genus_epithet
  end

  def set_subfamily
    self.subfamily = genus.subfamily if genus && genus.subfamily
  end
end

# Note: This is the superclass of Species and Subspecies, not to
# be confused with "species group" as used in taxonomy.

class SpeciesGroupTaxon < Taxon
  include Formatters::ItalicsHelper

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

  private

    def set_subfamily
      self.subfamily = genus.subfamily if genus && genus.subfamily
    end
end

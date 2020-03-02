class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true

  def recombination?
    # TODO: Check if this is true.
    # To avoid `NoMethodError` for records with protonyms above genus rank.
    protonym_name = protonym.name
    return false unless protonym_name.respond_to?(:genus_epithet)

    name.genus_epithet != protonym_name.genus_epithet
  end
end

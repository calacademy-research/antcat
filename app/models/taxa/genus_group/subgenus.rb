class Subgenus < GenusGroupTaxon
  belongs_to :genus

  # No taxa have a `subgenus_id` as of 2016.
  has_many :species

  validates :genus, presence: true

  def parent
    genus
  end

  def parent= parent_taxon
    raise unless parent_taxon.is_a? Genus
    self.genus = parent_taxon
  end

  def statistics valid_only: false
  end
end

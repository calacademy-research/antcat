class Subgenus < GenusGroupTaxon
  belongs_to :genus

  # No taxa have a `subgenus_id` as of 2016.
  has_many :species

  validates :genus, presence: true

  def parent
    genus
  end

  def parent= parent_taxon
    raise InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Genus)
    self.genus = parent_taxon
  end

  def update_parent new_parent
    raise InvalidParent.new(self, new_parent) unless new_parent.is_a?(Genus)
    self.genus = new_parent
  end

  def statistics valid_only: false
  end
end

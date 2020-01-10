class Subgenus < GenusGroupTaxon
  belongs_to :genus

  has_many :species, dependent: :restrict_with_error

  validates :genus, presence: true

  def parent
    genus
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Genus)
    self.genus = parent_taxon
  end

  def update_parent new_parent
    self.parent = new_parent
  end
end

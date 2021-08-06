# frozen_string_literal: true

class Species < SpeciesGroupTaxon
  belongs_to :subgenus, optional: true

  has_many :subspecies, dependent: :restrict_with_error
  has_many :infrasubspecies, dependent: :restrict_with_error

  scope :without_subgenus, -> { where(subgenus_id: nil) }

  validates(*(TAXA_COLUMNS - [:subfamily_id, :genus_id, :subgenus_id]), absence: true)

  def parent
    subgenus || genus
  end

  def parent= parent_taxon
    case parent_taxon
    when Subgenus
      self.subgenus = parent_taxon
      self.genus = parent_taxon.genus
    when Genus
      self.genus = parent_taxon
    else
      raise Taxa::InvalidParent.new(self, parent_taxon)
    end
    self.subfamily = parent_taxon.subfamily
  end

  # TODO: Remove all `#update_parent` once the data is in a better shape since
  # they are causing issues due to how records are modified in place without leaving any trace.
  def update_parent new_parent
    # TODO: This does not update names of subspecies.
    raise Taxa::TaxonHasSubspecies, 'Species has subspecies' if subspecies.any?
    raise Taxa::TaxonHasInfrasubspecies, 'Species has infrasubspecies' if infrasubspecies.any?

    change_name!(new_parent.name) unless new_parent == parent
    self.parent = new_parent
    update_descendants
  end

  def children
    subspecies
  end

  def childrens_rank_in_words
    "subspecies"
  end

  private

    def update_descendants
      subspecies.each do |subspecies|
        subspecies.update!(subfamily: subfamily, genus: genus)
      end
    end

    def change_name! new_parent_name
      name_string = [new_parent_name.genus_epithet, name.species_epithet].join(' ')
      ensure_name_can_be_changed! name_string
      name.name = name_string
      name.save!
    end
end

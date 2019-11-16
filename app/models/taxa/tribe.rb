class Tribe < Taxon
  belongs_to :subfamily

  has_many :subtribes
  has_many :genera
  has_many :species, through: :genera

  validates :subfamily, presence: true

  def parent
    subfamily
  end

  def parent= parent_taxon
    raise InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Subfamily)
    self.subfamily = parent_taxon
  end

  def update_parent new_parent
    self.parent = new_parent
    update_descendants_subfamilies
  end

  def children
    genera
  end

  def childrens_rank_in_words
    "genera"
  end

  private

    def update_descendants_subfamilies
      genera.each do |genus|
        genus.update(subfamily: subfamily)
        genus.species.each { |s| s.update(subfamily: subfamily) }
        genus.subspecies.each { |s| s.update(subfamily: subfamily) }
      end
    end
end

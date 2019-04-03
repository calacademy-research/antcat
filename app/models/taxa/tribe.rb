class Tribe < Taxon
  belongs_to :subfamily

  has_many :genera
  has_many :species, through: :genera

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
        genus.subfamily = subfamily
        genus.species.each { |s| s.subfamily = subfamily }
        genus.subspecies.each { |s| s.subfamily = subfamily }
      end
    end
end

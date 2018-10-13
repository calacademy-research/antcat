class Tribe < Taxon
  belongs_to :subfamily

  has_many :genera

  def parent
    subfamily
  end

  def parent= parent_taxon
    self.subfamily = parent_taxon
  end

  def update_parent new_parent
    if new_parent.is_a? Subfamily
      self.subfamily = new_parent
      update_descendants_subfamilies
    end
  end

  def children
    genera
  end

  def childrens_rank_in_words
    "genera"
  end

  # TODO don't know how to do this as a `has_many`.
  def species
    Species.where(genus_id: genera.pluck(:id))
  end

  def statistics valid_only: false
    get_statistics [:genera, :species], valid_only: valid_only
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

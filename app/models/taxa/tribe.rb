class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera
  attr_accessible :name, :protonym, :subfamily, :type_name

  def parent
    subfamily
  end

  def parent= parent_taxon
    self.subfamily = parent_taxon
  end

  def update_parent new_parent
    set_name_caches
    if new_parent.kind_of? Subfamily
      self.subfamily = new_parent
      update_descendants_subfamilies
    end
  end
  
  def children
    genera
  end

  def statistics
    get_statistics [:genera]
  end

  def siblings
    subfamily.tribes
  end

  private
    def update_descendants_subfamilies
      self.genera.each do |genus|
        genus.subfamily = self.subfamily
        genus.species.each { |s| s.subfamily = self.subfamily }
        genus.subspecies.each { |s| s.subfamily = self.subfamily }
      end
    end
end
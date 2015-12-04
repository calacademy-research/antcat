# coding: UTF-8
class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera
  attr_accessible :name, :protonym, :subfamily, :type_name

  def update_parent new_parent
    set_name_caches
    if new_parent.kind_of? Subfamily
      self.subfamily = new_parent
      update_descendants_subfamilies
    end
  end

  def add_antweb_attributes attributes
    attributes.merge subfamily: subfamily.name.to_s, tribe: name.to_s
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

  def inspect
    string = super
    if subfamily
      string << ", #{subfamily.name} #{subfamily.id}"
      string << " #{subfamily.status}" if subfamily.invalid?
    end
    string
  end

  private

  def update_descendants_subfamilies
    self.genera.each{ |g|
      g.subfamily = self.subfamily
      g.species.each{ |s| s.subfamily = self.subfamily }
      g.subspecies.each{ |s| s.subfamily = self.subfamily }
    }
  end

end
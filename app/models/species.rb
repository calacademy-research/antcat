# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  has_many :subspecies, class_name: 'Subspecies', order: :name
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def full_name
    "#{genus.name} #{name}"
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def statistics
    get_statistics [:subspecies]
  end

  def siblings
    genus.species
  end

end

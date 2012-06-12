# coding: UTF-8
class Subspecies < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :species
  validates_presence_of :species
  before_save :set_parent_taxa

  def set_parent_taxa
    self.subfamily = species.subfamily
    self.genus = species.genus
  end

  def statistics
  end

end

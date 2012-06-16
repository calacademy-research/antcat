# coding: UTF-8
class Subspecies < Taxon
  belongs_to :subfamily
  belongs_to :genus; validates :genus, presence: true
  belongs_to :species
  before_save :set_parent_taxa

  def set_parent_taxa
    self.subfamily = genus.subfamily
  end

  def statistics
  end

end

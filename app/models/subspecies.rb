# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  belongs_to :genus; validates :genus, presence: true
  belongs_to :species

  def statistics
  end

end

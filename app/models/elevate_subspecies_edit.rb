# coding: UTF-8
class ElevateSubspeciesEdit < EditingHistory
  belongs_to :old_species, class_name: 'Taxon'; validates :old_species, presence: true
  validates :taxon, presence: true
end

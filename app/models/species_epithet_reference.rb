# coding: UTF-8
class SpeciesEpithetReference < ForwardReference

  belongs_to :genus; validates :genus, presence: true

  def fixup
    species = Species.find_by_genus_id_and_epithet genus_id, epithet
    if species
      fixee.update_attribute :species, species
    else
      Progress.error "Couldn't find species for genus '#{genus.name}', epithet '#{epithet}'"
    end
  end

end

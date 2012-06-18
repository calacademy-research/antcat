# coding: UTF-8
class SpeciesEpithetReference < ForwardReference

  belongs_to :genus; validates :genus, presence: true

  def fixup
    species = Taxon.find_by_genus_id_and_epithet genus_id, epithet
    if species
      if species.kind_of? Subspecies
        Progress.error "Fixup for genus '#{genus.name}', epithet '#{epithet}' turned out to be a subspecies: #{species}"
      else
        fixee.update_attribute :species, species
      end
    else
      Progress.error "Couldn't find species for genus '#{genus.name}', epithet '#{epithet}'"
    end
  end

end

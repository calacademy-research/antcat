class MakeSpeciesIntoSubspecies < ActiveRecord::Migration
  def up
    species = Species.find_by_name 'Crematogaster smithi'
    new_parent_species = Species.find_by_name 'Crematogaster minutissima'
    species.become_subspecies_of new_parent_species

    species = Subspecies.find_by_name 'Formica rufa ravida'
    species.update_attribute :status, 'valid'
  end

  def down
  end
end

class FixCreightonidris < ActiveRecord::Migration
  def up
    ceratobasis = Taxon.find_by_name 'Ceratobasis'
    basiceros = Taxon.find_by_name 'Basiceros'
    creightonidris = Taxon.find_by_name 'Creightonidris'
    aspididris = Taxon.find_by_name 'Aspididris'

    creightonidris.become_not_junior_synonym_of ceratobasis
    creightonidris.become_junior_synonym_of basiceros

    aspididris.become_not_junior_synonym_of ceratobasis
    aspididris.become_junior_synonym_of basiceros
  end

  def down
  end
end

class FixPachychondyla < ActiveRecord::Migration
  def up
    name = Taxon.find_by_name_cache 'Pachycondyla darwinii indica'
    Taxon.update_all({name_id: name.name.id}, name_cache: 'Pachycondyla darwinii indica')
  end

  def down
  end
end

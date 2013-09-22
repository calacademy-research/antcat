class FixHaidoterminus < ActiveRecord::Migration
  def up
    haidomyrmecini = Taxon.find_by_name_cache 'Haidomyrmecini'
    Taxon.find_by_name_cache('Haidoterminus').update_attributes! tribe_id: haidomyrmecini.id
  end

  def down
  end
end

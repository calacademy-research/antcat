class AddOldSpeciesToHistory < ActiveRecord::Migration
  def up
    add_column :editing_history, :taxon_id, :integer rescue nil
    add_column :editing_history, :old_species_id, :integer rescue nil
  end

  def down
    remove_column :editing_history, :old_species_id
    remove_column :editing_history, :taxon_id
  end
end

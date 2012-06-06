class AddColumnsToName < ActiveRecord::Migration
  def change
    change_table :names do |t|
      t.string :type
      t.integer :genus_name_id
      t.integer :species_name_id
      t.string :subspecies_qualifier
      t.integer :next_subspecies_name_id
      t.integer :prior_subspecies_name_id
    end
  end
end

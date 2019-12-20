class AddSubspeciesIdToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :subspecies_id, :integer
    add_foreign_key :taxa, :taxa, column: :subspecies_id, name: :fk_taxa__subspecies_id__taxa__id
  end
end

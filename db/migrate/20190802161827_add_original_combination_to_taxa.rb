class AddOriginalCombinationToTaxa < ActiveRecord::Migration[5.2]
  def up
    add_column :taxa, :original_combination, :boolean, null: false, default: false
    execute "UPDATE taxa SET taxa.original_combination = TRUE WHERE taxa.status = 'original combination';"
  end

  def down
    remove_column :taxa, :original_combination
  end
end

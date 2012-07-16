class RemoveSynonymOf < ActiveRecord::Migration
  def up
    remove_column :taxa, :synonym_of_id
  end

  def down
    add_column :taxa, :synonym_of_id
  end
end

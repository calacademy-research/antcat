class AddSynonymOf < ActiveRecord::Migration
  def self.up
    add_column :taxa, :synonym_of_id, :integer
  end

  def self.down
    remove_column :taxa, :synonym_of_id
  end
end

class AddHomonymOf < ActiveRecord::Migration
  def self.up
    add_column :taxa, :homonym_of_id, :integer
  end

  def self.down
    remove_column :taxa, :homonym_of_id
  end
end

class AddStatusToTaxa < ActiveRecord::Migration
  def self.up
    remove_column :taxa, :available
    remove_column :taxa, :is_valid
    add_column :taxa, :status, :string
  end

  def self.down
    remove_column :taxa, :status
    add_column :taxa, :is_valid, :boolean
    add_column :taxa, :available, :boolean
  end
end

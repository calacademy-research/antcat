class AddTypeFieldToTaxa < ActiveRecord::Migration
  def self.up
    add_column :taxa, :type_field_id, :integer
  end

  def self.down
    remove_column :taxa, :type_field_id
  end
end

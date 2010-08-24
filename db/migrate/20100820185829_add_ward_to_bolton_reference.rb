class AddWardToBoltonReference < ActiveRecord::Migration
  def self.up
    add_column :bolton_refs, :ward_id, :integer
    add_column :bolton_refs, :suspect, :boolean
  end

  def self.down
    remove_column :bolton_refs, :ward_id
  end
end

class AddWardToBoltonReference < ActiveRecord::Migration
  def self.up
    add_column :bolton_refs, :ward_id, :integer
  end

  def self.down
    remove_column :bolton_refs, :ward_id
  end
end

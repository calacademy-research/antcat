class RemoveBoltonReferenceFields < ActiveRecord::Migration
  def self.up
    remove_column :bolton_references, :suspect
    remove_column :bolton_references, :ward_reference_id
  end

  def self.down
    add_column :bolton_references, :ward_reference_id, :integer
    add_column :bolton_references, :suspect, :boolean
  end
end

class AddBoltonReferenceType < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :type, :string
  end

  def self.down
    remove_column :bolton_references, :type
  end
end

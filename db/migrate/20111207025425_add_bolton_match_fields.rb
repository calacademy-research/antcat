class AddBoltonMatchFields < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :match_id, :integer
    add_column :bolton_references, :match_type, :string
  end

  def self.down
    remove_column :bolton_references, :match_type
    remove_column :bolton_references, :match_id
  end
end

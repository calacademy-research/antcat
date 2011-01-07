class AddNameToGenera < ActiveRecord::Migration
  def self.up
    add_column :genera, :name, :string
  end

  def self.down
    remove_column :genera, :name
  end
end

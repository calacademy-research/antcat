class AddFossilToGenus < ActiveRecord::Migration
  def self.up
    add_column :genera, :fossil, :boolean
  end

  def self.down
    remove_column :genera, :fossil
  end
end

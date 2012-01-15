class NilFossilIsFalse < ActiveRecord::Migration
  def self.up
    change_column :taxa, :fossil, :boolean, default: false, null: false
    execute "UPDATE taxa SET fossil = 0 WHERE fossil IS NULL"
  end

  def self.down
    change_column :taxa, :fossil, :boolean
  end
end

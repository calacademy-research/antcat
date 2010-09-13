class FixReferenceYear < ActiveRecord::Migration
  def self.up
    change_column :references, :year, :integer
  end

  def self.down
  end
end

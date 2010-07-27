class AddNumericYear < ActiveRecord::Migration
  def self.up
    add_column :refs, :numeric_year, :integer
  end

  def self.down
    remove_column :refs, :numeric_year
  end
end

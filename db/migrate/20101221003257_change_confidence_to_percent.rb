class ChangeConfidenceToPercent < ActiveRecord::Migration
  def self.up
    change_column :bolton_matches, :confidence, :integer
  end

  def self.down
    change_column :bolton_matches, :confidence, :float
  end
end

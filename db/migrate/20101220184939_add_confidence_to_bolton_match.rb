class AddConfidenceToBoltonMatch < ActiveRecord::Migration
  def self.up
    add_column :bolton_matches, :confidence, :float
  end

  def self.down
    remove_column :bolton_matches, :confidence
  end
end

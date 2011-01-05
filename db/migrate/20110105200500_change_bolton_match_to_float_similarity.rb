class ChangeBoltonMatchToFloatSimilarity < ActiveRecord::Migration
  def self.up
    remove_column :bolton_matches, :confidence
    add_column :bolton_matches, :similarity, :float
  end

  def self.down
    remove_column :bolton_matches, :similarity
    add_column :bolton_matches, :confidence, :integer
  end
end

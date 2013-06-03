class ExtractOriginalCombinationsAgain < ActiveRecord::Migration
  def up
    PaperTrail.enabled = false
    Taxon.extract_original_combinations true
  end

  def down
  end
end

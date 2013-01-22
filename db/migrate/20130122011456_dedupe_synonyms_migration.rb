class DedupeSynonymsMigration < ActiveRecord::Migration
  def up
    DedupeSynonyms.dedupe
  end

  def down
  end
end

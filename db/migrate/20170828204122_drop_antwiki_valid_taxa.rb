class DropAntwikiValidTaxa < ActiveRecord::Migration
  def up
    drop_table :antwiki_valid_taxa
  end

  def down
    # Nothing.
  end
end

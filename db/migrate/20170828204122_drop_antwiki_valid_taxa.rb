class DropAntwikiValidTaxa < ActiveRecord::Migration[4.2]
  def up
    drop_table :antwiki_valid_taxa
  end

  def down
    # Nothing.
  end
end

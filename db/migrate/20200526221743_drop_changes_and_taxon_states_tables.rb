# frozen_string_literal: true

class DropChangesAndTaxonStatesTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :changes
    drop_table :taxon_states
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

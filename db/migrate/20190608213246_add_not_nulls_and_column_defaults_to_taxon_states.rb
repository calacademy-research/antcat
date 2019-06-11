class AddNotNullsAndColumnDefaultsToTaxonStates < ActiveRecord::Migration[5.2]
  def up
    execute 'UPDATE taxon_states SET taxon_states.deleted = FALSE WHERE taxon_states.deleted IS NULL;'

    change_column_default :taxon_states, :deleted, false
    change_column_null :taxon_states, :deleted, false
  end

  def down
    change_column_default :taxon_states, :deleted, nil
    change_column_null :taxon_states, :deleted, true
  end
end

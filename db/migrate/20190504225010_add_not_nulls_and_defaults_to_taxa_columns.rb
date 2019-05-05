class AddNotNullsAndDefaultsToTaxaColumns < ActiveRecord::Migration[5.2]
  def up
    execute 'UPDATE taxa SET taxa.ichnotaxon = FALSE WHERE taxa.ichnotaxon IS NULL;'
    execute 'UPDATE taxa SET taxa.nomen_nudum = FALSE WHERE taxa.nomen_nudum IS NULL;'

    change_column_default :taxa, :ichnotaxon, false
    change_column_default :taxa, :nomen_nudum, false

    change_column_null :taxa, :auto_generated, false
    change_column_null :taxa, :ichnotaxon, false
    change_column_null :taxa, :nomen_nudum, false
  end

  def down
    change_column_default :taxa, :ichnotaxon, nil
    change_column_default :taxa, :nomen_nudum, nil

    change_column_null :taxa, :auto_generated, true
    change_column_null :taxa, :ichnotaxon, true
    change_column_null :taxa, :nomen_nudum, true
  end
end

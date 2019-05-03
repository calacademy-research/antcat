class AddNotNullsAndColumnDefaultsToProtonyms < ActiveRecord::Migration[5.2]
  def up
    execute 'UPDATE protonyms SET protonyms.fossil = FALSE WHERE protonyms.fossil IS NULL;'
    execute 'UPDATE protonyms SET protonyms.sic = FALSE WHERE protonyms.sic IS NULL;'

    change_column_default :protonyms, :fossil, false
    change_column_default :protonyms, :sic, false

    change_column_null :protonyms, :fossil, false
    change_column_null :protonyms, :sic, false
  end

  def down
    change_column_default :protonyms, :fossil, nil
    change_column_default :protonyms, :sic, nil

    change_column_null :protonyms, :fossil, true
    change_column_null :protonyms, :sic, true
  end
end

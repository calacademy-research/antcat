class ImportResult < ActiveRecord::Migration
  def up
    remove_column :bolton_references, :seen_in_latest_import
    add_column :bolton_references, :import_result, :string
  end

  def down
    remove_column :bolton_references, :import_result
    add_column :bolton_references, :seen_in_latest_import
  end
end

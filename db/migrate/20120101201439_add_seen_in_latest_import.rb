class AddSeenInLatestImport < ActiveRecord::Migration
  def up
    add_column :bolton_references, :seen_in_latest_import, :boolean
  end

  def down
    remove_column :bolton_references, :seen_in_latest_import
  end
end

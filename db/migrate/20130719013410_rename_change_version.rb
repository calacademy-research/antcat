class RenameChangeVersion < ActiveRecord::Migration
  def up
    rename_column :changes, :version_id, :paper_trail_version_id
  end

  def down
    rename_column :changes, :paper_trail_version_id, :version_id
  end
end

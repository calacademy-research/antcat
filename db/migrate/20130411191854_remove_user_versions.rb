class RemoveUserVersions < ActiveRecord::Migration
  def up
    Version.where(item_type: 'User').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

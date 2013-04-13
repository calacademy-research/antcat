class CleanReferenceSectionDeletes < ActiveRecord::Migration
  def up
    Version.where(item_type: 'ReferenceSection', event: 'destroy').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

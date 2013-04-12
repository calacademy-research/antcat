class DedupeReferenceSections < ActiveRecord::Migration
  def up
    ReferenceSection.dedupe
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

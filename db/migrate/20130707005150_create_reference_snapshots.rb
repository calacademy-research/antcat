class CreateReferenceSnapshots < ActiveRecord::Migration
  def up
    create_table :reference_snapshots, force: true do |t|
      t.integer     :reference_id
      t.integer     :reference_version_id
      t.integer     :journal_version_id
      t.integer     :publisher_version_id
      t.integer     :place_version_id
      t.integer     :nested_reference_version_id
      t.text        :author_versions

      t.timestamps
    end
  end

  def down
    drop_table :reference_snapshots
  end
end

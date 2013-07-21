class RecreateChangesFromVersions < ActiveRecord::Migration
  def up
    Change.destroy_all
    versions = Version.where(event: 'create', item_type: 'Taxon').order :created_at
    for version in versions.all
      Change.create! paper_trail_version: version, created_at: version.created_at
    end
  end
end

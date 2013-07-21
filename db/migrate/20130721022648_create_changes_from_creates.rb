class CreateChangesFromCreates < ActiveRecord::Migration
  def up
    for version in Version.where(event: 'create', item_type: 'Taxon').all
      Change.create! paper_trail_version: version
    end
  end

  def down
  end
end

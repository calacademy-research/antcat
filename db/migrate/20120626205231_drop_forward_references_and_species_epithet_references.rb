class DropForwardReferencesAndSpeciesEpithetReferences < ActiveRecord::Migration
  def up
    drop_table :forward_references
  end

  def down
    create_table :forward_references do |t|
    end
  end
end

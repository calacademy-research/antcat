class FixMissingSpecies < ActiveRecord::Migration
  def up
    Subspecies.fix_missing_species
  end

  def down
  end
end

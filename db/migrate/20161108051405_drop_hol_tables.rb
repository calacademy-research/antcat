# https://github.com/calacademy-research/antcat/issues/98
#
# Data was migrated in `20160415044632_copy_hol_id_to_taxon.rb`.
# We can use any 2016 db dump from before November 8 if we need to recreate.
# Closes #98. Related closed issue: #108.

class DropHolTables < ActiveRecord::Migration[4.2]
  def up
    drop_table :hol_data
    drop_table :hol_literature_pages
    drop_table :hol_literatures
    drop_table :hol_synonyms
    drop_table :hol_taxon_data
  end

  def down
    # Nothing.
  end
end

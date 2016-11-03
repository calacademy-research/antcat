# Roadmap:
# 1) [2.1 or 2.1.1] copy hol_id to Taxon
# 2) [2.1 or 2.1.1] remove most HOL-related code (probably all except HolTaxonDatum)
# 3) [future] remove remaining code
# 4) [future] drop database tables

# Making this migration independent from the code is not
# worth the time. Let's just copy what want and we can
# remove the tables from the db later.
# Also makes trying it out on the live site easier.

# Before migration (antcat.2016-03-01T10-15-03 db dump):
# PaperTrail::Version.count
# => 397363

# After migration:
# PaperTrail::Version.count
# => 397397 <-- 34 in total = tooltips only = OK
#
# Taxon.count
# => 72985
# Taxon.where.not(hol_id: nil).count
# => 49823
# Taxon.where(hol_id: nil).count
# => 23162
#
# Feed::Activity.count
# => 34 <-- tooltips only = OK

class CopyHolIdToTaxon < ActiveRecord::Migration
  def up
    add_column :taxa, :hol_id, :integer
    Taxon.find_each do |taxon|
      hol_id = extract_hol_id taxon
      taxon.update_columns(hol_id: hol_id) if hol_id
    end
  end

  def down
    remove_column :taxa, :hol_id, :integer
  end

  # Based on Taxon#hol_id (uncommented method when this was added):
  #  # it "provides a link if there's a valid hol_data entry"
  #  # it "provides a link if there's one invalid hol_data entry"
  #  # it "provides a link if there's one valid and one invalid hol_data entry"
  #  # it "provides no link if there are two invalid entries"
  #  # it "provides no link if there are two valid entries"
  def extract_hol_id taxon
    hol_data = HolTaxonDatum.where(antcat_taxon_id: taxon.id)

    valids, invalids = hol_data.partition(&:is_valid?)
    return valids.first.tnuid if valids.size == 1
    return invalids.first.tnuid if invalids.size == 1
  end
end

module DatabaseScripts
  class Quadrinomials < DatabaseScript
    def results
      Taxon.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :db_script_issues?

        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            ('Yes' if taxon.soft_validation_warnings.size.positive?)
          ]
        end
      end
    end
  end
end

__END__

description: >
  Quadrinomials cannot be 100% represented on AntCat since the lowest rank is subspecies.


  All current quadrinomials are stored in the database as `Subspecies` records. It is not possible to make
  any taxon belong to a subspecies (there is no `subspecies_id` column); it is simply skipped over,
  and the direct parent is instead the species. Since it cannot be validated, this means that the intended subspecies
  record may not even exist at all.


  Quadrinomials with db script issues must be fixed before we can attempt to migrate records by script.


  Issue: %github714

tags: [updated!, slow]
topic_areas: [catalog]

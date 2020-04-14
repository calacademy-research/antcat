# frozen_string_literal: true

module DatabaseScripts
  class Quadrinomials < DatabaseScript
    def results
      Subspecies.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Db script issues?'

        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            ('Yes' if taxon.soft_validations.failed?)
          ]
        end
      end
    end
  end
end

__END__

section: list
category: Catalog
tags: [slow-render]

description: >
  Quadrinomials cannot be 100% represented on AntCat since the lowest rank is subspecies.


  All current quadrinomials are stored in the database as `Subspecies` records. It is not possible to make
  any taxon belong to a subspecies (there is no `subspecies_id` column); it is simply skipped over,
  and the direct parent is instead the species. Since it cannot be validated, this means that the intended subspecies
  record may not even exist at all.


  Quadrinomials with db script issues must be fixed before we can attempt to migrate records by script.


  Issues: %github714, %github819

related_scripts:
  - Quadrinomials
  - QuadrinomialsToBeConverted

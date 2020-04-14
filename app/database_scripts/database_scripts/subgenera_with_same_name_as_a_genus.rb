# frozen_string_literal: true

module DatabaseScripts
  class SubgeneraWithSameNameAsAGenus < DatabaseScript
    def self.record_in_results? taxon
      same_named_taxa(taxon)&.exists?
    end

    def self.same_named_taxa taxon
      return unless taxon.persisted? # For the taxon form.
      return unless taxon.is_a?(Genus) || taxon.is_a?(Subgenus)

      if taxon.is_a?(Subgenus)
        subgenus_part_of_name = taxon.name.name.scan(/\((.*?)\)/)
        Genus.where(name_cache: subgenus_part_of_name)
      elsif taxon.is_a?(Genus)
        Subgenus.where("name_cache LIKE ?", "%(#{taxon.name.name})%")
      end.where.not(protonym: taxon.protonym)
    end

    def results
      subgenus_part_of_subgenera = Subgenus.pluck(:name_cache).map { |name| name.scan(/\((.*?)\)/) }.flatten
      Taxon.where(name_cache: subgenus_part_of_subgenera)
    end

    def render
      as_table do |t|
        t.header 'Subgenus', 'Subgenus authorship', 'Subgenus status',
                 'Taxon', 'Taxon origin', 'Taxon authorship', 'Taxon status',
                 'Same protonym?', 'Same now taxon?', 'Single yes to the left?', "Taxon's CVT is genus of subgenus?"
        t.rows do |taxon|
          subgenus = Subgenus.find_by("name_cache LIKE ?", "%(#{taxon.name_cache})%")

          same_protonym = taxon.protonym == subgenus.protonym
          same_now_taxon = taxon.now == subgenus.now
          taxons_cvt_is_genus_of_subgenus = (subgenus.genus == taxon.current_valid_taxon)

          [
            taxon_link(subgenus),
            subgenus.authorship_reference.keey,
            subgenus.status,

            taxon_link(taxon),
            origin_warning(taxon),
            taxon.authorship_reference.keey,
            taxon.status,

            ('Yes' if same_protonym),
            ('Yes' if same_now_taxon),
            ('Yes' if same_protonym ^ same_now_taxon),
            ('Yes' if taxons_cvt_is_genus_of_subgenus)
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Catalog
tags: [slow]

issue_description: This genus or subgenus has the same name as another taxon (comparing genus name vs. subgenus part of name).

description: >
  This is not necessarily incorrect, but it seems we have a bunch genus records that were never placed at the rank of genus.


  Rows with a "Yes" in the "Single yes to the left" columns are probably not correct.


  This script has some overlaps with %dbscript:TypeTaxaWithIssues

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart

  - SubgeneraWithSameNameAsAGenus

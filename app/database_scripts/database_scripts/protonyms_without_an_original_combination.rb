# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutAnOriginalCombination < DatabaseScript
    def results
      protonyms.includes(:name)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            taxa_quick_fix_links(protonym)
          ]
        end
      end
    end

    private

      def protonyms
        records = Protonym.species_group_names.
          joins("LEFT OUTER JOIN taxa ON protonyms.id = taxa.protonym_id AND taxa.original_combination = True").
          where(taxa: { id: nil }).group('protonyms.id').distinct
        Protonym.where(id: records.select(:id))
      end

      def taxa_quick_fix_links protonym
        protonym.taxa.map do |taxon|
          quick_fix_link(taxon, protonym) << " " << CatalogFormatter.link_to_taxon(taxon)
        end.join('<br>')
      end

      def quick_fix_link taxon, protonym
        return +'Cannot quick-fix (incompatible name types)' unless taxon.name.class == protonym.name.class

        link_to 'Flag as Original combination! -->',
          flag_as_original_combination_quick_and_dirty_fix_path(taxon_id: taxon.id),
          method: :post, remote: true, class: 'btn-normal btn-tiny'
      end
  end
end

__END__

section: research
tags: [protonyms, combinations, original-combinations, has-quick-fix, updated!]

description: >
  "Original combination" as in a `Taxon` flagged as `original_combination`.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies

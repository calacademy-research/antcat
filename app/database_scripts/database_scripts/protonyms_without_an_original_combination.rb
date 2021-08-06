# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutAnOriginalCombination < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      protonyms.limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Protonym'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym
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
  end
end

__END__

section: research
tags: [protonyms, combinations]

description: >
  "Original combination" as in a `Taxon` flagged as `original_combination`.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies

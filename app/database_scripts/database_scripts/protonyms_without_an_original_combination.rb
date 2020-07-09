# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutAnOriginalCombination < DatabaseScript
    LIMIT = 500

    def results
      protonyms.limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
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
        records = Protonym.
          joins("LEFT OUTER JOIN taxa ON protonyms.id = taxa.protonym_id AND taxa.original_combination = True").
          where("taxa.id IS NULL").group(:protonym_id).distinct
        Protonym.where(id: records.select(:id))
      end
  end
end

__END__

section: research
category: Catalog
tags: []

description: >
  "Original combination" as in a `Taxon` flagged as `original_combination`.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination

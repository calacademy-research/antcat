# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutAnOriginalCombination < DatabaseScript
    def results
      protonyms.limit(100)
    end

    def statistics
      "Results: #{protonyms.count}"
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
  WIP.


  This script can be ignored since flagging taxa as `original_combination` is not very important to us right now.


  Limited to the first 200.


related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination

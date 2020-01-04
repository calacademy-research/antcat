module DatabaseScripts
  class ValidTaxaThatMayBeSynonyms < DatabaseScript
    VALID_INDICATORS = Regexp.union(
      [
        /as (subfamily|tribe|genus|subgenus)/i,
        /subspecies of/i,
        /in genus/i,
        /in \{tax /i,
        /revived/i,
        /its junior synonym/i,
        /senior synonym/i,
        /incertae sedis/i,
        /status as species/i,
        /raised/i,
        /conserved over /i
      ]
    )

    def results
      taxa = Taxon.joins(:history_items).valid.where(unresolved_homonym: false).
        where("taxon_history_items.taxt REGEXP ?", "junior synonym").
        order(:name_cache).distinct

      taxa.to_a.reject { |taxon| probably_valid? taxon.history_items }
    end

    private

      def probably_valid? history_items
        last_valid_indication(history_items) >= last_junior_synonym_indication(history_items)
      end

      def last_junior_synonym_indication history_items
        history_items.reverse.find { |item| item.taxt =~ /junior synonym/i }.position
      end

      def last_valid_indication history_items
        history_items.reverse.find { |item| item.taxt =~ VALID_INDICATORS }.try(:position) || -1
      end
  end
end

__END__

category: Catalog
tags: [list]

description: >
  This script creates a list of all taxa with history items that mention
  `junior synonym`. Taxa with items containing "valid indicators" (eg.
  `as genus`, see source) after the `junior synonym` entry are removed
  from the list; the rest are shown in this table.

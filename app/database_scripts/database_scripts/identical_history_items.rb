module DatabaseScripts
  class IdenticalHistoryItems < DatabaseScript
    def results
      dupes = TaxonHistoryItem.joins(:taxon).
        where.not(taxa: { type: ['Species', 'Subspecies', 'Infrasubspecies'] }).
        where("LENGTH(taxt) > 30").group(:taxt).having("COUNT(taxon_history_items.id) >  1")
      TaxonHistoryItem.where(taxt: dupes.pluck(:taxt))
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'taxt'
        t.rows do |history_item|
          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(history_item.taxon),
            Detax[history_item.taxt]
          ]
        end
      end
    end
  end
end

__END__

category: Taxt
tags: []

description: >
  Items belonging to species and below, and items with less than 30 characters are excluded (too many false positives).

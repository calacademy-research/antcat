module DatabaseScripts
  class HistoryItemsWithoutRefOrTaxTags < DatabaseScript
    def results
      TaxonHistoryItem.where(TaxonHistoryItem::NO_REF_OR_TAX_TAG).includes(:taxon)
    end

    def render
      as_table do |t|
        t.header :history_item, :taxon, :status, :taxt, :taxon_nomen_nudum?, :looks_like_protonym_data?, :redundant_nomen_nudum_item?
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            ('Yes' if taxon.nomen_nudum?),
            ('Yes' if looks_like_it_belongs_to_the_protonym?(taxt)),
            ('Yes' if redundant_nomen_nudum_item?(taxt, taxon))
          ]
        end
      end
    end

    def looks_like_it_belongs_to_the_protonym? taxt
      taxt.starts_with?(',') ||
        taxt =~ /[A-Z]{5,}/
    end

    def redundant_nomen_nudum_item? taxt, taxon
      taxt == '<i>Nomen nudum</i>' && taxon.nomen_nudum? && taxon.history_items.count == 1
    end
  end
end

__END__

title: History items without <code>ref</code> or <code>tax</code> tags
category: Taxt
tags: [new!]

description: >
  "Looks like protonym data" = item starts with a comma, or contains five or more uppercase letters


  "Redundant nomen nudum item" = item only says "nomen nudum" + taxon is a *nomen nudum* + taxon has no other history items

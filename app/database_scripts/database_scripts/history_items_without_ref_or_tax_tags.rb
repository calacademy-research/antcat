module DatabaseScripts
  class HistoryItemsWithoutRefOrTaxTags < DatabaseScript
    def results
      TaxonHistoryItem.where(TaxonHistoryItem::NO_REF_OR_TAX_TAG).
        includes(taxon: { protonym: :name })
    end

    def render
      as_table do |t|
        t.header :history_item, :taxon, :status, :taxt, :quick_actions,
          :looks_like_protonym_data?, :protonym, :protonym_synopsis
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon
          protonym = taxon.protonym

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            convert_bolton_link(history_item),
            ('Yes' if looks_like_it_belongs_to_the_protonym?(taxt)),
            protonym.decorate.link_to_protonym,
            protonym.synopsis
          ]
        end
      end
    end

    def looks_like_it_belongs_to_the_protonym? taxt
      taxt.starts_with?(',') ||
        taxt =~ /[A-Z]{5,}/
    end

    def convert_bolton_link history_item
      link_to 'Convert Bolton!', convert_bolton_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
        method: :post, remote: true, class: 'btn-warning btn-tiny'
    end
  end
end

__END__

title: History items without <code>ref</code> or <code>tax</code> tags
category: Taxt
tags: [updated!]

description: >
  "Looks like protonym data" = item starts with a comma, or contains five or more uppercase letters

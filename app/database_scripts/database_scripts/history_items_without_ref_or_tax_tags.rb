# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithoutRefOrTaxTags < DatabaseScript
    def results
      TaxonHistoryItem.where(Taxt::HistoryItemCleanup::NO_REF_OR_TAX_OR_PRO_TAG).
        includes(taxon: { protonym: :name })
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick actions',
          'Looks like protonym data?', 'Protonym'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon
          protonym = taxon.protonym
          looks_like_it_belongs_to_the_protonym = looks_like_it_belongs_to_the_protonym?(taxt)
          simple_known_format = simple_known_format?(taxt)

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            (convert_bolton_link(history_item) unless looks_like_it_belongs_to_the_protonym || simple_known_format),
            ('Yes' if looks_like_it_belongs_to_the_protonym),
            protonym.decorate.link_to_protonym
          ]
        end
      end
    end

    def simple_known_format? taxt
      taxt.in?(['Unavailable name', '<i>Nomen nudum</i>'])
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

section: research
category: Taxt
tags: [has-quick-fix]

description: >
  "Looks like protonym data" = item starts with a comma, or contains five or more uppercase letters

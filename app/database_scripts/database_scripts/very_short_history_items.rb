module DatabaseScripts
  class VeryShortHistoryItems < DatabaseScript
    MAX_CHARACTERS = 15

    def results
      TaxonHistoryItem.where('CHAR_LENGTH(taxt) < ?', MAX_CHARACTERS).includes(:taxon)
    end

    def render
      as_table do |t|
        t.header :taxon_history_item, :taxon, :taxt

        t.rows do |taxon_history_item|
          [
            link_taxon_history_item(taxon_history_item),
            markdown_taxon_link(taxon_history_item.taxon),
            TaxtPresenter[taxon_history_item.taxt].to_html
          ]
        end
      end
    end

    private

      def link_taxon_history_item taxon_history_item
        "<a href='/taxon_history_items/#{taxon_history_item.id}'>#{taxon_history_item.id}</a>"
      end
  end
end

__END__
description: >
  Less than 15 characters.
topic_areas: [taxt]

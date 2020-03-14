module DatabaseScripts
  class TaxtItemsWithHardcodedNames < DatabaseScript
    def results
      models_and_ids = {}

      Taxt::TAXTABLES.each do |(model, _table, field)|
        models_and_ids[model] ||= []
        models_and_ids[model] += model.where("#{field} LIKE '%hardcoded_name%'").pluck(:id)
      end

      models_and_ids.reject { |_model, ids| ids.empty? }
    end

    def statistics
      "Results: #{cached_results.values.sum(&:size)}"
    end

    def render
      as_table do |t|
        t.header 'item_type', 'item_id'

        cached_results.each do |model, ids|
          t.rows(ids) do |id|
            item = model.find(id)

            [
              model,
              attempt_to_link_item(model.name, id),
              (item.taxt if item.is_a?(TaxonHistoryItem))
            ]
          end
        end
      end
    end

    private

      def attempt_to_link_item item_type, item_id
        case item_type
        when "TaxonHistoryItem"
          link_to(item_id, taxon_history_item_path(item_id))
        when "ReferenceSection"
          link_to(item_id, reference_section_path(item_id))
        when "Taxon"
          link_to(item_id, catalog_path(item_id))
        when "Citation"
          taxa_ids = Citation.find(item_id).protonym.taxa.pluck :id
          taxa_ids.map do |taxon_id|
            "#{item_id} " + link_to("(Taxon #{taxon_id})", catalog_path(taxon_id))
          end.join(', ')
        else
          "#{item_type} (#{item_id})"
        end
      end
  end
end

__END__

category: Taxt

description: >
  This script contains all taxt items containing the string `hardcoded_name`.


  Most of them were added when `nam` tags were replaced with their content.


  Names can be removed from this list by editing the item and
  removing the `hardcoded_name` HTML comment, likewise, items can be added to this list by
  including `hardcoded_name` anywhere in the content of a taxt (these HTML comments
  are hidden in the catalog).

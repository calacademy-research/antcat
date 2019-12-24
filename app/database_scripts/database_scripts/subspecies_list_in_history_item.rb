# TODO: See copy-pasta in `SubspeciesHistoryItemIssues`.

module DatabaseScripts
  class SubspeciesListInHistoryItem < DatabaseScript
    def results
      TaxonHistoryItem.where('taxt LIKE ?', "%Current subspecies%")
    end

    def render
      @all_extracted_ids = []
      @convertable_count = 0
      @not_convertable_count = 0

      table = as_table do |t| # rubocop:disable Metrics/BlockLength
        t.header :convertable?, :id, :species, :taxon_status, :history_item, :ids_same?,
          :additional, :all_extracted_are_subspecies?,
          :non_valid_statuses_of_extracted, :valid_subspecies_ids, :extracted_ids

        t.rows do |history_item|
          extracted_ids = extract_taxt_ids history_item

          @all_extracted_ids.concat extracted_ids

          ids_same = ids_same?(history_item, extracted_ids)
          additional = extract_additional(history_item)
          all_extracted_are_subspecies = all_extracted_are_subspecies?(extracted_ids)
          non_valid_statuses_of_extracted = Taxon.where.not(status: Status::VALID).where(id: extracted_ids).pluck(:status).presence

          convertable = ids_same && additional.blank? && all_extracted_are_subspecies && non_valid_statuses_of_extracted.blank?

          if convertable
            @convertable_count += 1
          else
            @not_convertable_count += 1
          end

          [
            (convertable ? 'Yes' : '<span class="bold-warning">No</span>'),
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(history_item.taxon),
            history_item.taxon.status,
            history_item.taxt,
            ('No' unless ids_same),
            additional,
            ('No' unless all_extracted_are_subspecies),
            non_valid_statuses_of_extracted,
            valid_subspecies_ids(history_item),
            extracted_ids
          ]
        end
      end

      bonus_stats << table
    end

    private

      def bonus_stats
        <<~HTML.html_safe
          <div class='callout no-border-callout logged-in-only-background'>
            Convertable: #{@convertable_count}
            <br>
            Not convertable: #{@not_convertable_count}
            <br>

            <br>

            Total extracted IDs: #{@all_extracted_ids.size}
            <br>
            Total unique extracted IDs: #{@all_extracted_ids.uniq.size}
            <br>
            ...of which are species: #{Species.where(id: @all_extracted_ids).count}
            <br>
            ...of which are subspecies: #{Subspecies.where(id: @all_extracted_ids).count}
            <br>
            Total valid subspecies: #{Subspecies.valid.count}
            <br>
            Statuses of extracted taxa: #{Taxon.where(id: @all_extracted_ids).group(:status).count}
          </div>
        HTML
      end

      def extract_additional history_item
        cleaned = history_item.taxt
        cleaned = cleaned.gsub(/Current subspecies: nominal plus /, '')

        valid_subspecies_ids(history_item).each do |id|
          cleaned = cleaned.gsub(/\{tax #{id}\}/, '')
        end

        cleaned = cleaned.gsub(', ', '')
        cleaned
      end

      def ids_same? history_item, extracted_ids
        valid_subspecies_ids(history_item) == extracted_ids
      end

      def valid_subspecies_ids history_item
        history_item.taxon.subspecies.valid.pluck(:id).sort
      end

      def extract_taxt_ids history_item
        history_item.taxt.scan(/\{tax (\d+)\}/).flatten.map(&:to_i).sort
      end

      def all_extracted_are_subspecies? extracted_ids
        Subspecies.where(id: extracted_ids).count == extracted_ids.size
      end
  end
end

__END__

category: Taxt
tags: [slow]

description: >
  The goal of this script is to eliminate data inconsistencies and duplication, so we can either create a "virtual history item" or list subspecies outside of the history section.


  All history items that contain `"Current subspecies"` are included here.


  * "No" in the "IDs same?" column means that taxon IDs (`tax` tags) extracted from the history items were not the same as the IDs of the species' valid subspecies.


  * "Additional" is what remains after removing `tax` tags that can be genrated from the species valid subspecies.


  * This script can be considered empty when there are no "No"s in the "IDs same" or "All extracted are subspecies" columns, and all "Additional" fields are blank. "Non-valid statuses of extracted" should probably also be all blank.


  Issue: %github780

related_scripts:
  - SubspeciesListInHistoryItem
  - SubspeciesListInHistoryItemVsSubspeciesFromDatabase

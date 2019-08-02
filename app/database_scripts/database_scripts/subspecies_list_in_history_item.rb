module DatabaseScripts
  class SubspeciesListInHistoryItem < DatabaseScript
    def results
      TaxonHistoryItem.where('taxt LIKE ?', "%Current subspecies%")
    end

    def render
      all_extracted_ids = []

      as_table do |t|
        t.header :id, :species, :taxon_status, :history_item, :ids_same?,
          :additional, :all_extracted_are_subspecies?,
          :non_valid_statuses_of_extracted, :valid_subspecies_ids, :extracted_ids

        t.rows do |history_item|
          extracted_ids = extract_taxt_ids history_item

          all_extracted_ids.concat extracted_ids

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(history_item.taxon),
            history_item.taxon.status,
            history_item.taxt,
            ('No' unless ids_same?(history_item, extracted_ids)),
            additional(history_item),
            ('No' unless all_extracted_are_subspecies?(extracted_ids)),
            Taxon.where.not(status: Status::VALID).where(id: extracted_ids).pluck(:status).presence,
            valid_subspecies_ids(history_item),
            extracted_ids
          ]
        end

        # $stdout.puts "Total extracted IDs: #{all_extracted_ids.size}"
        # $stdout.puts "Total unique extracted IDs: #{all_extracted_ids.uniq.size}"
        # $stdout.puts "...of which are species: #{Species.where(id: all_extracted_ids).count}"
        # $stdout.puts "...of which are subspecies: #{Subspecies.where(id: all_extracted_ids).count}"
        # $stdout.puts "Total valid subspecies: #{Subspecies.valid.count}"
        # $stdout.puts "Statuses of extracted taxa: #{Taxon.where(id: all_extracted_ids).group(:status).count}"
      end
    end

    private

      def additional history_item
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

description: >
  The goal of this script is to eliminate data inconsistencies and duplication, so we can either create a "virtual history item" or list subspecies outside of the history section.


  All history items that contain `"Current subspecies"` are included here.


  * "No" in the "IDs same?" column means that taxon IDs (`tax` tags) extracted from the history items were not the same as the IDs of the species' valid subspecies.


  * "Additional" is what remains after removing `tax` tags that can be genrated from the species valid subspecies.


  * This script can be considered empty when there are no "No"s in the "IDs same" or "All extracted are subspecies" columns, and all "Additional" fields are blank. "Non-valid statuses of extracted" should probably also be all blank.


  **Some stats as of writing:**

  `Total extracted IDs: 1919`

  `Total unique extracted IDs: 1916`

  `...of which are species: 45`

  `...of which are subspecies: 1871`

  `Total valid subspecies: 1897`

  `Statuses of extracted taxa: {"homonym"=>1, "obsolete combination"=>26, "original combination"=>1, "synonym"=>51, "unavailable"=>5, "valid"=>1832}`

tags: [slow]
topic_areas: [taxt]

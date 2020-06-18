# frozen_string_literal: true

module DatabaseScripts
  class MissingTaxaToBeCreated < DatabaseScript
    # For `EmptyStatus`.
    def results
      missing_names_to_be_created_by_count
    end

    def statistics
      <<~RESULTS.html_safe
        Results: #{missing_names_to_be_created_by_count.size}
      RESULTS
    end

    def render
      as_table do |t|
        t.header 'Name', 'Count'
        t.rows(missing_names_to_be_created_by_count) do |(normalized_name, count)|
          [
            normalized_name,
            count
          ]
        end
      end
    end

    private

      def missing_names_to_be_created_by_count
        @_missing_names_to_be_created_by_count ||= missing_names_by_count.reject do |(normalized_name, _count)|
          Taxon.where(name_cache: normalized_name).exists?
        end
      end

      def missing_names_by_count
        @_missing_names_by_count = begin
          all_hardcoded_names = all_hardcoded_taxts.scan(Taxt::MISSING_TAG_REGEX).flatten.map do |hardcoded_name|
            hardcoded_name.gsub(%r{</?i>}, '')
          end

          tally = all_hardcoded_names.each_with_object(Hash.new(0)) do |normalized_name, hsh|
            hsh[normalized_name] += 1
          end

          tally.sort_by(&:second).reverse
        end
      end

      def all_hardcoded_taxts
        TaxonHistoryItem.where('taxt LIKE ?', "%#{Taxt::MISSING_TAG_START}%").pluck(:taxt).join
      end
  end
end

__END__

section: main
category: Taxt
tags: [new!]

issue_description:

description: >
  Hardcoded names from `missing` tags in history items, for which there exist no `Taxon` record.


  See related script below for individual history items.


  Once `Taxon` records have been created, `missing` tags can be replaced using the quick-button in the linked script.

related_scripts:
  - HistoryItemsWithMissingTags
  - MissingTaxaToBeCreated

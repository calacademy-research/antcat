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
        t.header 'Name', 'Count', 'Quick-add button', 'Quick-add attributes'
        t.rows(missing_names_to_be_created_by_count) do |(normalized_name, count)|
          quick_adder = QuickAdd::FromHardcodedNameFactory.create_quick_adder(normalized_name)

          [
            normalized_name,
            count,
            (new_taxon_link(quick_adder) if quick_adder.can_add?),
            quick_adder&.synopsis
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

      def new_taxon_link quick_adder
        label = "Add #{quick_adder.taxon_class.name}"
        link_to label, new_taxa_path(quick_adder.taxon_form_params), class: "btn-tiny btn-normal"
      end
  end
end

__END__

section: main
category: Taxt
tags: [has-quick-fix, slow]

issue_description:

description: >
  Hardcoded names from `missing` tags in history items, for which there exist no `Taxon` record.


  The "quick-add" button opens the taxon form with prefilled values, which can be adjusted before saving.


  See related script below for individual history items.


  Once `Taxon` records have been created, `missing` tags can be replaced using the quick-button in the linked script.

related_scripts:
  - HistoryItemsWithMissingTagsQueue1
  - HistoryItemsWithMissingTagsQueue2
  - MissingTaxaToBeCreated

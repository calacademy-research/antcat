# frozen_string_literal: true

module VirtualHistoryItems
  class SubspeciesList
    attr_private_initialize :taxon

    def relevant_for_taxon?
      return @_relevant_for_taxon if defined? @_relevant_for_taxon
      @_relevant_for_taxon ||= taxon.is_a?(Species) && taxon.valid_status? && taxon.subspecies.valid.exists?
    end

    def publicly_visible?
      true
    end

    def reason_hidden
      <<~STR.html_safe
        This should not happen. Does any history items of this species start with "Current subspecies:"?
      STR
    end

    def render formatter: ::CatalogFormatter
      content = 'Current subspecies: nominal plus '.html_safe

      subspecies_links = TaxonQuery.new(taxon.subspecies.valid).order_by_epithet.to_a.map do |subspecies|
        subspecies_link subspecies, formatter
      end

      content << subspecies_links.join(', ').html_safe
      content << '.'
    end

    private

      attr_reader :formatter

      def subspecies_link subspecies, formatter
        label = subspecies_link_label subspecies

        string = formatter.link_to_taxon_with_label(subspecies, label).html_safe
        string << ' (unresolved junior homonym)' if subspecies.unresolved_homonym?
        string
      end

      def subspecies_link_label subspecies
        "<i>#{'†' if subspecies.fossil?}#{subspecies.name.short_name}</i>"
      end
  end
end

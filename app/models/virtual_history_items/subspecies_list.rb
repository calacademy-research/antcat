module VirtualHistoryItems
  class SubspeciesList
    def initialize taxon
      @taxon = taxon
    end

    def relevant_for_taxon?
      return @relevant_for_taxon if defined? @relevant_for_taxon
      @relevant_for_taxon ||= taxon.is_a?(Species) && taxon.valid_taxon? && taxon.subspecies.valid.exists?
    end

    def publicly_visible?
      return @publicly_visible if defined? @publicly_visible
      @publicly_visible ||= !taxon.subspecies_list_in_history_items.exists?
    end

    def reason_hidden
      <<~STR.html_safe
        hidden because this species has a subspecies list in a history item &ndash;
        delete the plaintext history item to show this item to all visitors instead
      STR
    end

    def render formatter: ::DefaultFormatter
      content = 'Current subspecies: nominal plus '.html_safe

      subspecies_links = taxon.subspecies.valid.order_by_epithet.to_a.map do |subspecies|
        subspecies_link subspecies, formatter
      end

      content << subspecies_links.join(', ').html_safe
      content << '.'
    end

    private

      attr_reader :taxon, :formatter

      def subspecies_link subspecies, formatter
        string = formatter.link_to_taxon(subspecies).html_safe
        string << ' (unresolved junior homonym)' if subspecies.unresolved_homonym?
        string
      end
  end
end

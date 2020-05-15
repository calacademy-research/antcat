# frozen_string_literal: true

# TODO: Add support for this in the AntWeb export, also once the scripts has been cleared.

class TypeTaxonExpander
  def initialize taxon
    @taxon = taxon
    @type_taxt = taxon.type_taxt
    @type_taxon = taxon.type_taxon
  end

  def expansion
    return '' if compact_status.blank?

    ' ('.html_safe + compact_status + ')'.html_safe
  end

  private

    attr_reader :taxon, :type_taxt, :type_taxon

    def compact_status
      @_compact_status ||= type_taxon.most_recent_before_now.decorate.compact_status
    end
end

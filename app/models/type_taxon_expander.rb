# frozen_string_literal: true

# TODO: Remove this and related code once `TaxaWithUncommonTypeTaxts` and `TaxaWithTypeTaxa` as been cleared.
# TODO: Add support for this in the AntWeb export, also once the scripts has been cleared.

class TypeTaxonExpander
  def initialize taxon
    @taxon = taxon
    @type_taxt = taxon.type_taxt
    @type_taxon = taxon.type_taxon
  end

  def can_expand?
    return false if type_taxt && !Protonym.common_type_taxt?(type_taxt)

    true
  end

  def reason_cannot_expand
    return if can_expand?
    @_reason_cannot_expand ||= reasons_cannot_expand
  end

  def expansion ignore_can_expand: false
    unless ignore_can_expand
      return unless can_expand?
    end

    return '' if compact_status.blank?

    ' ('.html_safe + compact_status + ')'.html_safe
  end

  private

    attr_reader :taxon, :type_taxt, :type_taxon

    def compact_status
      @_compact_status ||= type_taxon.most_recent_before_now.compact_status
    end

    def reasons_cannot_expand
      reasons = []

      reasons << <<~HTML if type_taxt && !Protonym.common_type_taxt?(type_taxt)
        This taxon's <code>type_taxt</code> of not a "common" <code>type_taxt</code>.
        <br>
        This taxon's <code>type_taxt</code>: <code>#{taxon.type_taxt}</code>
      HTML

      if reasons.blank?
        '????'
      else
        reasons.join('<br><br>').html_safe
      end
    end
end

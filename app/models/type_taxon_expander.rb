# TODO: Remove this and related code once `TaxaWithUncommonTypeTaxts` and `TaxaWithTypeTaxa` as been cleared.
# TODO: Add support for this in the AntWeb export, also once the scripts has been cleared.

class TypeTaxonExpander
  def initialize taxon
    @taxon = taxon
    @type_taxt = taxon.type_taxt
    @type_taxon = taxon.type_taxon
  end

  def can_expand?
    return false if type_taxt.present? && !Protonym.common_type_taxt?(type_taxt)
    return false if current_valid_taxon_chain?

    true
  end

  def reason_cannot_expand
    return if can_expand?
    @reason_cannot_expand ||= reasons_cannot_expand
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

    def current_valid_taxon_chain?
      return false unless type_taxon.current_valid_taxon
      type_taxon.current_valid_taxon.current_valid_taxon.present?
    end

    def compact_status
      @compact_status ||= type_taxon.compact_status
    end

    def reasons_cannot_expand
      reasons = []

      reasons << <<~HTML if type_taxt.present? && !Protonym.common_type_taxt?(type_taxt)
        This taxon's <code>type_taxt</code> of not a "common" <code>type_taxt</code>.
        <br>
        This taxon's <code>type_taxt</code>: <code>#{taxon.type_taxt}</code>
      HTML

      reasons << <<~HTML if current_valid_taxon_chain?
        the <code>current_valid_taxon</code> of the <code>type_taxon</code> has a
        <code>current_valid_taxon</code> of its own.
      HTML

      if reasons.blank?
        '????'
      else
        reasons.join('<br><br>').html_safe
      end
    end
end

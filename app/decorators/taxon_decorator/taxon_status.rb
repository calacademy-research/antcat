class TaxonDecorator::TaxonStatus
  def initialize taxon
    @taxon = taxon
  end

  def call
    # Note: Cleverness is used here to make these queries (e.g.: obsolete_combination?)
    # appear as tags. That's how CSS does its coloring.
    labels = []
    labels << "<i>incertae sedis</i> in #{taxon.incertae_sedis_in}" if taxon.incertae_sedis_in

    labels << if taxon.homonym? && taxon.homonym_replaced_by
                "homonym replaced by #{taxon.homonym_replaced_by.decorate.link_to_taxon}"
              elsif taxon.unidentifiable?
                "unidentifiable"
              elsif taxon.unresolved_homonym?
                "unresolved junior homonym"
              elsif taxon.nomen_nudum?
                "<i>nomen nudum</i>"
              elsif taxon.synonym?
                "junior synonym#{format_senior_synonym}"
              elsif taxon.obsolete_combination?
                "an obsolete combination of #{format_valid_combination}"
              elsif taxon.unavailable_misspelling?
                "a misspelling of #{format_valid_combination}"
              elsif taxon.unavailable_uncategorized?
                "see #{format_valid_combination}"
              elsif taxon.nonconfirming_synonym?
                "a non standard form of #{format_valid_combination}"
              elsif taxon.invalid?
                Status[taxon].to_s.dup
              else
                "valid"
              end

    labels << 'ichnotaxon' if taxon.ichnotaxon?
    labels.join(', ').html_safe
  end

  private
    attr_reader :taxon

    def format_senior_synonym
      current_valid_taxon = taxon.current_valid_taxon_including_synonyms
      return '' unless current_valid_taxon

      ' of current valid taxon ' << current_valid_taxon.decorate.link_to_taxon
    end

    # TODO handle nil differently or we may end up with eg "a misspelling of ".
    def format_valid_combination
      current_valid_taxon = taxon.current_valid_taxon_including_synonyms
      return '' unless current_valid_taxon

      current_valid_taxon.decorate.link_to_taxon
    end
end

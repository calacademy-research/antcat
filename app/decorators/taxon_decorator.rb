class TaxonDecorator < ApplicationDecorator
  delegate_all

  def link_to_taxon
    link_to_taxon_with_label taxon.name_with_fossil
  end

  def link_to_taxon_with_label label
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def link_each_epithet
    TaxonDecorator::Header.new(taxon).link_each_epithet
  end

  # Currently accepts very confusing arguments.
  # `include_invalid` tells `TaxonDecorator::Statistics.new.statistics` to remove
  # invalid taxa from the already generated hash of counts. This is the older method.
  # `valid_only` was written for performance reasons; it makes `Taxon#statistics`
  # ignore invalid taxa to begin with.
  def statistics valid_only: false, include_invalid: true
    statistics = taxon.statistics valid_only: valid_only
    return '' unless statistics

    content = TaxonDecorator::Statistics.new.statistics statistics, include_invalid: include_invalid
    return '' if content.blank?

    helpers.content_tag :div, content, class: 'statistics'
  end

  def headline use_ant_web_formatter: false
    TaxonDecorator::Headline.new(taxon, use_ant_web_formatter: use_ant_web_formatter).headline
  end

  def child_lists
    TaxonDecorator::ChildList.new(taxon).child_lists
  end

  def genus_species_header_notes_taxt
    return unless taxon.genus_species_header_notes_taxt.present?
    helpers.content_tag :div,
      TaxtPresenter[taxon.genus_species_header_notes_taxt].to_html,
      class: 'genus_species_header_notes_taxt'
  end

  def taxon_status
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

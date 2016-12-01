class TaxonDecorator::Header
  include ERB::Util
  include ActionView::Helpers::UrlHelper # For `#link_to`.
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper
  include CatalogHelper

  def initialize taxon
    @taxon = taxon
  end

  def header
    content = content_tag :span, header_name(@taxon), class: "taxon name"
    content << second_part

    content_tag :div, content, class: 'header'
  end

  private
    def second_part
      return original_combination_second_part if @taxon.original_combination?
      stardard_second_part
    end

    def stardard_second_part
      content = ''.html_safe
      content << content_tag(:span, @taxon.authorship_string, class: "authorship")
      content << content_tag(:span, @taxon.decorate.taxon_status, class: "status")
      content << content_tag(:span, (@taxon.name.gender || '').html_safe, class: "gender")
      content << content_tag(:span, review_state, class: "review_state")
      content
    end

    def original_combination_second_part
      content = ''.html_safe
      if @taxon.current_valid_taxon
        content << content_tag(:span, " see ", class: 'see')
        content << content_tag(:span, header_name(@taxon.current_valid_taxon))
      end
      content
    end

    # This links the different parts of the binomial name. Only applicable to
    # species and below, since higher ranks consists of a single word.
    def header_name taxon
      return taxon.decorate.link_to_taxon unless taxon.kind_of? SpeciesGroupTaxon
      return nonconforming_name_header_link(taxon) if taxon.name.nonconforming_name

      string = genus_link_or_blank_string taxon

      if taxon.is_a? Species
        return string << header_link(taxon, taxon.name.epithet_html.html_safe)
      end

      species = taxon.species
      if species
        string << header_link(species, species.name.epithet_html.html_safe)
        string << ' '.html_safe
        epithets_without_species = taxon.name.epithets.split(' ')[1..-1].join ' '
        string << header_link(taxon, italicize(epithets_without_species))
      else
        string << header_link(taxon, italicize(taxon.name.epithets))
      end

      string
    end

    # This name is a radical misspelling, or an obsolete name formulation.
    # Display literally, but link genus if there is one.
    def nonconforming_name_header_link taxon
      string = genus_link_or_blank_string taxon
      string << header_link(taxon, italicize(taxon.name.epithets))
    end

    def genus_link_or_blank_string taxon
      return "".html_safe unless taxon.genus
      taxon.genus.decorate.link_to_taxon << " "
    end

    def header_link taxon, label
      taxon.decorate.link_to_taxon_with_label label
    end

    def review_state
      return unless @taxon.waiting?
      "This taxon has been changed; changes awaiting approval"
    end
end

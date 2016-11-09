class TaxonDecorator::Header
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper
  include CatalogHelper

  include RefactorHelper

  def initialize taxon
    @taxon = taxon
  end

  def header
    return original_combination_header if @taxon.original_combination?
    normal_header
  end

  private
    def normal_header
      content_tag :div, class: 'header' do
        content = ''.html_safe
        content << content_tag(:span, header_name, class: css_classes_for_rank(@taxon))
        content << content_tag(:span, header_authorship, class: "authorship")
        content << content_tag(:span, status, class: "status")
        content << content_tag(:span, gender, class: "gender")
        content << content_tag(:span, review_state, class: "review_state")
        content
      end
    end

    def original_combination_header
      content_tag :div, class: 'header' do
        content = ''.html_safe
        content << content_tag(:span, header_name, class: css_classes_for_rank(@taxon))
        if @taxon.current_valid_taxon
          content << content_tag(:span, " see ", class: 'see')
          content << content_tag(:span, header_name_for_taxon(@taxon.current_valid_taxon))
        end
        content
      end
    end

    def header_name
      header_name_for_taxon @taxon
    end

    def header_name_for_taxon taxon
      return non_species_group_header_link(taxon) unless taxon.kind_of? SpeciesGroupTaxon

      string = ''.html_safe

      genus = taxon.genus
      if genus
        string << header_link(genus, genus.name.to_html_with_fossil(genus.fossil?))
      else
        # TODO fix this
        # As of March 2016 there are 9 subspecies without a genus,
        # `Subspecies.where(genus: nil).count`,
        # and question marks are better than unrescued error + 404.
        # Same issue as in Exporters::Antweb::MonkeyPatchTaxon::Subspecies
        string << "???"
      end

      string << ' '.html_safe
      if taxon.name.nonconforming_name
        # This name is a radical misspelling, or an obsolete name formulation.
        # Display literally.
        string << header_link(taxon, italicize(taxon.name.epithets))
      else
        if taxon.is_a? Species
          string << header_link(taxon, taxon.name.epithet_html.html_safe)
        else
          species = taxon.species
          if species
            string << header_link(species, species.name.epithet_html.html_safe)
            string << ' '.html_safe
            epithets_without_species = taxon.name.epithets.split(' ')[1..-1].join ' '
            string << header_link(taxon, italicize(epithets_without_species))
          else
            string << header_link(taxon, italicize(taxon.name.epithets))
          end
        end
      end

      string
    end

    # TODO see LinkHelper#link.
    def header_link taxon, label
      link label, %{/catalog/#{taxon.id}}
    end

    def non_species_group_header_link taxon
      string = ''.html_safe
      string << header_link(taxon, taxon.name.to_html_with_fossil(taxon.fossil?))
    end

    def header_authorship
      @taxon.authorship_string
    end

    def status
      @taxon.decorate.taxon_status
    end

    def gender
      (@taxon.name.gender || '').html_safe
    end

    def review_state
      return unless @taxon.waiting?
      "This taxon has been changed; changes awaiting approval"
    end
end

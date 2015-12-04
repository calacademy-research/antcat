class TaxonDecorator::Header
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper

  def initialize taxon, user=nil
    @taxon = taxon
    @user = user
  end

  #########
  public def header
    @taxon.decorate.header
    return original_combination_header if @taxon.original_combination?
    content_tag :div, class: 'header' do
      content = ''.html_safe
      content << content_tag(:span, header_name, class: Formatters::CatalogFormatter.css_classes_for_rank(@taxon))
      content << content_tag(:span, header_authorship, class: :authorship)
      content << content_tag(:span, status, class: :status)
      content << content_tag(:span, gender, class: :gender)
      content << content_tag(:span, review_state, class: :review_state)
      content
    end
  end

  private def original_combination_header
    content_tag :div, class: 'header' do
      content = ''.html_safe
      content << content_tag(:span, header_name, class: Formatters::CatalogFormatter.css_classes_for_rank(@taxon))
      if @taxon.current_valid_taxon
        content << content_tag(:span, " see ", class: 'see')
        content << content_tag(:span, header_name_for_taxon(@taxon.current_valid_taxon))
      end
      content << link_to_edit_taxon if link_to_edit_taxon
      content
    end
  end

  private def header_link taxon, label
    link label, %{/catalog/#{taxon.id}}, target: nil
  end

  private def header_name
    header_name_for_taxon @taxon
  end

  private def header_name_for_taxon taxon
    string = ''.html_safe
    if taxon.kind_of?(Species) or taxon.kind_of?(Subspecies)
      genus = taxon.genus
      string << header_link(genus, genus.name.to_html_with_fossil(genus.fossil?))
      string << ' '.html_safe
      if taxon.name.nonconforming_name
        # This name is a radical misspelling, or an obsolete name formulation.
        # Display literally.
        string << header_link(taxon, italicize(taxon.name.epithets))
      else
        if taxon.kind_of? Species
          string << header_link(taxon, taxon.name.epithet_html.html_safe)
        else
          taxon.kind_of? Subspecies
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
    else
      string << header_link(taxon, taxon.name.to_html_with_fossil(taxon.fossil?))
    end
    string
  end

  private def header_authorship
    @taxon.authorship_string
  end

  private def status
    self.class.taxon_status @taxon
  end

  def self.taxon_status taxon
    #
    # Note: Cleverness is used here to make these queries (e.g.: obsolete_combination?)
    # appear as tags. That's how CSS does its coloring.
    #
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[taxon.incertae_sedis_in].to_s}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{link_to_taxon(taxon.homonym_replaced_by)}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << "<i>nomen nudum</i>"
    elsif taxon.synonym?
      label = 'junior synonym'
      label << format_senior_synonym(taxon)
      labels << label
    elsif taxon.obsolete_combination?
      label = 'an obsolete combination of '
      label << format_valid_combination(taxon)
      labels << label
    elsif taxon.unavailable_misspelling?
      label = 'a misspelling of '
      label << format_valid_combination(taxon)
      labels << label

    elsif taxon.unavailable_uncategorized?
      label = 'see '
      label << format_valid_combination(taxon)
      labels << label
    elsif taxon.nonconfirming_synonym?
      label = 'a non standard form of '
      label << format_valid_combination(taxon)
      labels << label
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      labels << label
    else
      labels << 'valid'
    end

    labels << 'ichnotaxon' if taxon.ichnotaxon?

    labels.join(', ').html_safe
  end

  private def gender
    (@taxon.name.gender || '').html_safe
  end

  private def review_state
    if @taxon.waiting?
      "This taxon has been changed; changes awaiting approval"
    end
  end

  def self.format_senior_synonym taxon
    if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
      return ' of current valid taxon ' << link_to_taxon(current_valid_taxon)
    end
    ''
  end

  def self.format_valid_combination taxon
    if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
      return link_to_taxon(current_valid_taxon)
    end
    ''
  end

end
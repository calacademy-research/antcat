# coding: UTF-8
class Formatters::CatalogTaxonFormatter < Formatters::TaxonFormatter
  include Formatters::ButtonFormatter
  include Formatters::LinkFormatter

  def include_invalid; true end
  def expand_references?; true end

  def link_to_other_site
    link_to_antweb @taxon
  end

  def link_to_edit_taxon
    if @taxon.can_be_edited_by? @user
      button 'Edit', 'edit_button', 'data-edit-location' => "/taxa/#{@taxon.id}/edit"
    end
  end

  def link_to_review_change
    if @taxon.can_be_reviewed_by? @user
      button 'Review change', 'review_button', 'data-review-location' => "/changes/#{@taxon.last_change.id}"
    end
  end

  def self.link_to_taxon taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  #########
  def header
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

  def original_combination_header
    content_tag :div, class: 'header' do
      content = ''.html_safe
      content << content_tag(:span, header_name, class: Formatters::CatalogFormatter.css_classes_for_rank(@taxon))
      content << content_tag(:span, " see ", class: 'see')
      content << content_tag(:span, header_name_for_taxon(@taxon.current_valid_taxon))
      content
    end
  end

  def header_link taxon, label
    link label, %{/catalog/#{taxon.id}}, target: nil
  end

  def header_name
    header_name_for_taxon @taxon
  end

  def header_name_for_taxon taxon
    string = ''.html_safe
    if taxon.kind_of?(Species) or taxon.kind_of?(Subspecies)
      genus = taxon.genus
      string << header_link(genus, genus.name.to_html_with_fossil(genus.fossil?))
      string << ' '.html_safe
      if taxon.kind_of? Species
        string << header_link(taxon, taxon.name.epithet_html.html_safe)
      else taxon.kind_of? Subspecies
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
    else
      string << header_link(taxon, taxon.name.to_html_with_fossil(taxon.fossil?))
    end
    string
  end

  def header_authorship
    @taxon.authorship_string
  end

  def status
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[@taxon.incertae_sedis_in].to_s}" if @taxon.incertae_sedis_in
    if @taxon.homonym? && @taxon.homonym_replaced_by
      labels << "homonym replaced by #{self.class.link_to_taxon(@taxon.homonym_replaced_by)}"
    elsif @taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif @taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif @taxon.nomen_nudum?
      labels << "<i>nomen nudum</i>"
    elsif @taxon.synonym?
      label = 'junior synonym'
      label << senior_synonym_list
      labels << label
    elsif @taxon.invalid?
      label = Status[@taxon].to_s.dup
      labels << label
    else
      labels << 'valid'
    end

    labels << 'ichnotaxon' if @taxon.ichnotaxon?

    labels.join(', ').html_safe
  end

  def gender
    (@taxon.name.gender || '').html_safe
  end

  def review_state
    if @taxon.waiting?
      "This taxon has been changed and is awaiting approval"
    end
  end

  def senior_synonym_list
    return '' unless @taxon.senior_synonyms.count > 0
    ' of ' << @taxon.senior_synonyms.map {|e| self.class.link_to_taxon(e)}.join(', ')
  end

  #########
  def change_history
    return if @taxon.old?
    change = @taxon.last_change
    return unless change
    content_tag :span, class: 'change_history' do
      content = ''.html_safe

      content << "Added by #{format_doer_name(@taxon.added_by)} ".html_safe
      content << format_time_ago(change.created_at).html_safe

      if @taxon.approved?
        content << "; approved by #{format_doer_name(@taxon.approver)} ".html_safe
        content << format_time_ago(change.approved_at).html_safe
      end

      content
    end
  end

end

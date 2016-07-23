class TaxonDecorator < ApplicationDecorator
  delegate_all

  def link_to_taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def header
    TaxonDecorator::Header.new(taxon).header
  end

  def statistics options = {}
    statistics = taxon.statistics
    return '' unless statistics
    string = TaxonDecorator::Statistics.new.statistics(statistics, options)
    helpers.content_tag :div, string, class: 'statistics'
  end

  def headline
    TaxonDecorator::Headline.new(taxon).headline
  end

  def child_lists
    TaxonDecorator::ChildList.new(taxon).child_lists
  end

  def history
    TaxonDecorator::History.new(taxon).history
  end

  def genus_species_header_notes_taxt
    return unless taxon.genus_species_header_notes_taxt.present?
    helpers.content_tag :div, detaxt(taxon.genus_species_header_notes_taxt), class: 'genus_species_header_notes_taxt'
  end

  def references
    return unless taxon.reference_sections.present?
    helpers.content_tag :div, class: 'reference_sections' do
      taxon.reference_sections.reduce(''.html_safe) do |content, section|
        content << reference_section(section)
      end
    end
  end

  def change_history
    return if taxon.old?
    change = taxon.latest_change
    return unless change

    helpers.content_tag :span, class: 'change_history' do
      content = ''.html_safe
      if change.change_type == 'create'
        content << "Added by"
      else
        content << "Changed by"
      end
      content << " #{change.decorate.format_changed_by} ".html_safe
      content << change.decorate.format_created_at.html_safe

      if taxon.approved?
        # I don't fully understand this case;
        # it appears that somehow, we're able to generate "changes" without affiliated
        # taxon_states. not clear to me how this happens or whether this should be allowed.
        # Workaround: If the taxon_state is showing "approved", go get the most recent change
        # that has a noted approval.
        approved_change = Change.where(<<-SQL.squish, change.user_changed_taxon_id).last
          user_changed_taxon_id = ? AND approved_at IS NOT NULL
        SQL
        content << "; approved by #{approved_change.decorate.format_approver_name} ".html_safe
        content << approved_change.decorate.format_approved_at.html_safe
      end

      content
    end
  end

  def taxon_status
    # Note: Cleverness is used here to make these queries (e.g.: obsolete_combination?)
    # appear as tags. That's how CSS does its coloring.
    labels = []
    labels << "<i>incertae sedis</i> in #{taxon.incertae_sedis_in}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{taxon.homonym_replaced_by.decorate.link_to_taxon}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << "<i>nomen nudum</i>"
    elsif taxon.synonym?
      label = 'junior synonym'
      label << format_senior_synonym
      labels << label
    elsif taxon.obsolete_combination?
      label = 'an obsolete combination of '
      label << format_valid_combination
      labels << label
    elsif taxon.unavailable_misspelling?
      label = 'a misspelling of '
      label << format_valid_combination
      labels << label
    elsif taxon.unavailable_uncategorized?
      label = 'see '
      label << format_valid_combination
      labels << label
    elsif taxon.nonconfirming_synonym?
      label = 'a non standard form of '
      label << format_valid_combination
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

  def name_description
    string =
      case taxon
      when Subfamily
        'subfamily'
      when Tribe
        string = "tribe of "
        parent = taxon.subfamily
        string << (parent ? parent.name.to_html : '(no subfamily)')
      when Genus
        string = "genus of "
        parent = taxon.tribe ? taxon.tribe : taxon.subfamily
        string << (parent ? parent.name.to_html : '(no subfamily)')
      when Species
        string = "species of "
        parent = taxon.parent
        string << parent.name.to_html
      when Subgenus
        string = "subgenus of "
        parent = taxon.parent
        string << parent.name.to_html
      when Subspecies
        string = "subspecies of "
        parent = taxon.species
        string << (parent ? parent.name.to_html : '(no species)')
      else
        ''
      end

    # TODO: Joe test this case
    if taxon[:unresolved_homonym] == true && taxon.new_record?
      string = " secondary junior homonym of #{string}"
    elsif !taxon[:collision_merge_id].nil? && taxon.new_record?
      target_taxon = Taxon.find_by_id(taxon[:collision_merge_id])
      string = " merge back into original #{target_taxon.name_html_cache}"
    end

    string = "new #{string}" if taxon.new_record?
    string.html_safe
  end

  private
    def reference_section section
      helpers.content_tag :div, class: 'section' do
        [:title_taxt, :subtitle_taxt, :references_taxt].reduce(''.html_safe) do |content, field|
          if section[field].present?
            content << helpers.content_tag(:div, detaxt(section[field]), class: field)
          end
          content
        end
      end
    end

    def detaxt taxt
      return '' unless taxt.present?
      Taxt.to_string taxt
    end

    def format_senior_synonym
      if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
        return ' of current valid taxon ' << current_valid_taxon.decorate.link_to_taxon
      end
      ''
    end

    def format_valid_combination
      if current_valid_taxon = taxon.current_valid_taxon_including_synonyms
        return current_valid_taxon.decorate.link_to_taxon
      end
      ''
    end
end

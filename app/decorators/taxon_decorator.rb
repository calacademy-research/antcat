class TaxonDecorator < ApplicationDecorator
  delegate_all

  def link_to_taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def header
    TaxonDecorator::Header.new(taxon).header
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
    helpers.content_tag :div,
      detaxt(taxon.genus_species_header_notes_taxt),
      class: 'genus_species_header_notes_taxt'
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
    change = taxon.last_change
    return unless change

    helpers.content_tag :span, class: 'change_history' do
      content = if change.change_type == 'create'
                  "Added by"
                else
                  "Changed by"
                end.html_safe
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

  def name_description
    string =
      case taxon
      when Subfamily
        "subfamily"
      when Tribe
        parent = taxon.subfamily
        "tribe of " << (parent ? parent.name.to_html : '(no subfamily)')
      when Genus
        parent = taxon.tribe ? taxon.tribe : taxon.subfamily
        "genus of " << (parent ? parent.name.to_html : '(no subfamily)')
      when Species
        parent = taxon.parent
        "species of " << parent.name.to_html
      when Subgenus
        parent = taxon.parent
        "subgenus of " << parent.name.to_html
      when Subspecies
        parent = taxon.species
        "subspecies of " << (parent ? parent.name.to_html : '(no species)')
      else
        ''
      end

    # TODO: Joe test this case
    if taxon[:unresolved_homonym] == true && taxon.new_record?
      string = " secondary junior homonym of #{string}"
    elsif !taxon[:collision_merge_id].nil? && taxon.new_record?
      target_taxon = Taxon.find_by(id: taxon[:collision_merge_id])
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

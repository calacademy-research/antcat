module TaxonHelper
  # This is for the edit taxa form. Advanced search uses another.
  def biogeographic_region_options_for_select value = nil
    options_for_select([[nil, nil]], value) <<
      options_for_select(Taxon::BIOGEOGRAPHIC_REGIONS, value)
  end

  def taxon_link_or_deleted_string id, deleted_label = nil
    if Taxon.exists? id
      Taxon.find(id).decorate.link_to_taxon
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def reset_epithet taxon
    case taxon
    when Family  then taxon.name.name
    when Species then taxon.name.genus_epithet
    else              ""
    end
  end

  def default_name_string taxon
    return unless taxon.is_a?(SpeciesGroupTaxon) || taxon.is_a?(Subgenus)
    parent = Taxon.find params[:parent_id]
    parent.name.name
  end

  def taxon_name_description taxon
    return unless taxon.new_record?

    if taxon.unresolved_homonym?
      "new secondary junior homonym of #{taxon.parent.name_html_cache}".html_safe
    elsif params[:collision_resolution].present?
      target_taxon = Taxon.find_by(id: params[:collision_resolution])
      "new merge back into original #{target_taxon.name_html_cache}".html_safe
    end
  end

  def taxon_change_history taxon
    return if taxon.old?
    change = taxon.last_change
    return unless change

    content_tag :span, class: 'change-history' do
      content = if change.change_type == 'create'
                  "Added by"
                else
                  "Changed by"
                end.html_safe
      content << " #{change.decorate.format_changed_by} ".html_safe
      content << change.decorate.format_created_at.html_safe

      if taxon.approved?
        approved_change = Change.where(<<-SQL.squish, change.taxon_id).last
          taxon_id = ? AND approved_at IS NOT NULL
        SQL

        if approved_change
          content << "; approved by #{approved_change.decorate.format_approved_by} ".html_safe
          content << approved_change.decorate.format_approved_at.html_safe
        end
      end

      content
    end
  end
end

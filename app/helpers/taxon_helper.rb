# This helper is for code related to editing taxa, ie not taxa in general.
# There are some similar methods in `CatalogHelper` (via `_editor_buttons.haml`),
# that we may want to DRY up.

module TaxonHelper
  def sort_by_status_and_name taxa
    taxa.sort do |a, b|
      if a.status == b.status
        a.name_cache <=> b.name_cache # name ascending
      else
        b.status <=> a.status # status descending
      end
    end
  end

  # This is for the edit taxa form. Advanced search uses another.
  def biogeographic_region_options_for_select value = nil
    options_for_select([[nil, nil]], value) <<
      options_for_select(BiogeographicRegion::REGIONS, value)
  end

  def add_child_button taxon
    return unless user_can_edit?

    child_ranks = { family:    "subfamily",
                    subfamily: "genus",
                    tribe:     "genus",
                    genus:     "species",
                    subgenus:  "species",
                    species:   "subspecies" }

    rank_to_add = child_ranks[taxon.rank.to_sym]
    return unless rank_to_add.present?

    url = new_taxa_path rank_to_create: rank_to_add, parent_id: taxon.id
    link_to "Add #{rank_to_add}", url, class: "btn-normal"
  end

  def add_tribe_button taxon
    return unless user_can_edit? && taxon.is_a?(Subfamily)

    url = new_taxa_path rank_to_create: 'tribe', parent_id: taxon.id
    link_to "Add tribe", url, class: "btn-normal"
  end

  def convert_to_subspecies_button taxon
    return unless taxon.is_a? Species

    url = new_taxa_convert_to_subspecies_path taxon
    link_to 'Convert to subspecies', url, class: "btn-normal"
  end

  def elevate_to_species_button taxon
    return unless taxon.is_a? Subspecies

    message = "Are you sure you want to elevate this subspecies to species?"
    link_to 'Elevate to species', elevate_to_species_taxa_path(taxon),
      method: :put, class: "btn-saves", data: { confirm: message }
  end

  def delete_unreferenced_taxon_button taxon
    return if taxon.any_nontaxt_references?

    message = <<-MSG.squish
      Are you sure you want to delete this taxon? Note: It may take a few
      moments to check that this taxon isn't being referenced.
    MSG

    link_to 'Delete', destroy_unreferenced_taxa_path(taxon), method: :delete,
      class: "btn-delete", data: { confirm: message }
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
    when Family  then taxon.name.to_s
    when Species then taxon.name.genus_epithet
    else              ""
    end
  end

  def default_name_string taxon
    return unless taxon.kind_of? SpeciesGroupTaxon
    parent = Taxon.find params[:parent_id]
    parent.name.name
  end

  def taxon_name_description taxon
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

  def taxon_change_history taxon
    return if taxon.old?
    change = taxon.last_change
    return unless change

    content_tag :span, class: 'change_history' do
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
end

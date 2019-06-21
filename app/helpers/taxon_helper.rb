module TaxonHelper
  def taxon_link_or_deleted_string id, deleted_label = nil
    taxon = Taxon.find_by(id: id)
    if taxon
      taxon.link_to_taxon
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def reference_link_or_deleted_string id, deleted_label = nil
    reference = Reference.find_by(id: id)
    if reference
      reference.decorate.expandable_reference
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def default_name_string taxon
    return unless taxon.is_a?(SpeciesGroupTaxon) || taxon.is_a?(Subgenus)
    return taxon.species.name.name + ' ' if taxon.is_a?(Subspecies)
    taxon.genus.name.name + ' '
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

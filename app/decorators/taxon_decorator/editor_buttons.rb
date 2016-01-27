module TaxonDecorator::EditorButtons

  def editor_buttons
    helpers.content_tag :div, class: 'editor_buttons' do
      content = ''.html_safe
      if taxon.original_combination?
        content << ' ' << link_to_edit_taxon if link_to_edit_taxon
      else
        content << ' ' << link_to_edit_taxon if link_to_edit_taxon
        content << ' ' << link_to_delete_taxon if link_to_delete_taxon
        content << ' ' << link_to_review_change if link_to_review_change
      end
      content
    end
  end

  def link_to_edit_taxon
    if helpers.user_can_edit?
      helpers.link_to "Edit", helpers.edit_taxa_path(taxon), class: "btn-edit"
    end
  end

  private
    def link_to_review_change
      return unless helpers.user_can_review_changes?

      if taxon.can_be_reviewed? && taxon.latest_change
        helpers.link_to 'Review change', "/changes/#{taxon.latest_change.id}", class: "btn-normal"
      end
    end

    def link_to_delete_taxon
      return unless helpers.user_is_superadmin?

      helpers.link_to 'Delete', "#", id: "delete_button", class: "btn-delete",
        data: { 'delete-location' => helpers.taxa_path(taxon), "taxon-id" => taxon.id }
    end
end

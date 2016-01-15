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
    if taxon.can_be_edited_by? get_current_user
      helpers.link_to "Edit", "/taxa/#{taxon.id}/edit", class: "btn-edit"
    end
  end

  private
    def link_to_review_change
      if taxon.can_be_reviewed_by?(get_current_user) && taxon.latest_change
        parameters = { 'data-review-location' => "/changes/#{taxon.latest_change.id}" }
        helpers.button 'Review change', 'review_button', parameters
      end
    end

    def link_to_delete_taxon
      if get_current_user.try :is_superadmin?
        parameters = { 'data-delete-location' => "/taxa/#{taxon.id}", 'data-taxon-id' => "#{taxon.id}" }
        helpers.button 'Delete', 'delete_button', parameters
      end
    end
end

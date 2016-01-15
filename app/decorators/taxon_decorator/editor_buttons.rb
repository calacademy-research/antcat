class TaxonDecorator::EditorButtons
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper

  def initialize taxon, user=nil
    @taxon = taxon
    @user = user
  end

  def editor_buttons
    content_tag :div, class: 'editor_buttons' do
      content = ''.html_safe
      if @taxon.original_combination?
        content << ' ' << link_to_edit_taxon if link_to_edit_taxon
      else
        content << ' ' << link_to_edit_taxon if link_to_edit_taxon
        content << ' ' << link_to_delete_taxon if link_to_delete_taxon
        content << ' ' << link_to_review_change if link_to_review_change
      end
      content
    end
  end

  private
    def link_to_edit_taxon
      if @taxon.can_be_edited_by? @user
        link_to "Edit", "/taxa/#{@taxon.id}/edit", class: "btn-edit"
      end
    end

    def link_to_review_change
      if @taxon.can_be_reviewed_by?(@user) && @taxon.latest_change
        parameters = { 'data-review-location' => "/changes/#{@taxon.latest_change.id}" }
        button 'Review change', 'review_button', parameters
      end
    end

    def link_to_delete_taxon
      if @user.try :is_superadmin?
        parameters = { 'data-delete-location' => "/taxa/#{@taxon.id}/delete", 'data-taxon-id' => "#{@taxon.id}" }
        button 'Delete', 'delete_button', parameters
      end
    end
end

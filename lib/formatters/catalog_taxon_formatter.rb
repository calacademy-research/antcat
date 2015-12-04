# coding: UTF-8
class Formatters::CatalogTaxonFormatter < Formatters::TaxonFormatter
  include Formatters::ButtonFormatter
  include Formatters::LinkFormatter

  private def include_invalid;
    true
  end

  private def expand_references?;
    true
  end

  private def link_to_other_site
    link_to_antweb @taxon
  end


  private def link_to_delete_taxon
    unless @user.nil?
      if @user.is_superadmin?
        button 'Delete', 'delete_button', {'data-delete-location' => "/taxa/#{@taxon.id}/delete", 'data-taxon-id' => "#{@taxon.id}"}
      end
    end
  end

  private def link_to_edit_taxon
    if @taxon.can_be_edited_by? @user
      button 'Edit', 'edit_button', 'data-edit-location' => "/taxa/#{@taxon.id}/edit"
    end
  end

  private def link_to_review_change
    if @taxon.can_be_reviewed_by?(@user) && @taxon.latest_change
      button 'Review change', 'review_button', 'data-review-location' => "/changes/#{@taxon.latest_change.id}"
    end
  end

  def self.link_to_taxon taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  #########
  public def header
    @taxon.decorate.header
  end

  public def change_history
    @taxon.decorate.change_history
  end

end

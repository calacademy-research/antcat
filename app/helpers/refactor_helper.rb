module RefactorHelper
  def include_invalid;
    true
  end

  def expand_references?;
    true
  end

  def link_to_edit_taxon
    if @taxon.can_be_edited_by? @user
      button 'Edit', 'edit_button', 'data-edit-location' => "/taxa/#{@taxon.id}/edit"
    end
  end

  def link_to_taxon taxon #fix AntWeb
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  # duplicated in Formatters::Formatter
  def add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] =~ /[.!?]/
    string
  end

end
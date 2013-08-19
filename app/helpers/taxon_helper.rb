# coding: UTF-8
module TaxonHelper

  def name_description taxon
    string = case taxon
    when Subfamily
      'subfamily'
    when Genus
      string = "genus of "
      parent = taxon.subfamily
      string << (parent ? parent.name.to_html : '(no subfamily)')
    when Species
      string = "species of "
      parent = taxon.genus
      string << parent.name.to_html
    when Subspecies
      string = "subspecies of "
      parent = taxon.species
      string << (parent ? parent.name.to_html : '(no species)')
    else
      ''
    end
    string = 'new ' + string if taxon.new_record?
    string.html_safe
  end

  def link_to_taxon taxon
    label = taxon.name.to_html.html_safe
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  def format_protonym taxon
    formatter = Formatters::ReferenceFormatter
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << Formatters::ReferenceFormatter.format(reference)
    string << reference.key.document_link(current_user)
    string << reference.key.goto_reference_link
    string
  end

end

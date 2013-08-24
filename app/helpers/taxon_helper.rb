# coding: UTF-8
module TaxonHelper

  def link_to_taxon taxon
    label = taxon.name.to_html.html_safe
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

end

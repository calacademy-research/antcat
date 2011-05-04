module TaxonomicHistoryHelper

  def taxonomic_history taxon
    string = taxon.taxonomic_history
    homonym_replaced = taxon.homonym_replaced
    if homonym_replaced
      string << "<p>Homonym replaced by <i>#{taxon.name.upcase}</i></p>"
      string << content_tag('p') do
        link_to homonym_replaced.name, browser_taxatry_path(homonym_replaced)
      end
      string << homonym_replaced.taxonomic_history
    end
    string
  end

end

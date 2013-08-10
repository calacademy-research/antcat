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

end

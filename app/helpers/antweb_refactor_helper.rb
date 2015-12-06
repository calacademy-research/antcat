module AntwebRefactorHelper

  def link_to_taxon taxon
    link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
  end

  def link_to_other_site
    link_to_antcat @taxon
  end

  def detaxt taxt
    return '' unless taxt.present?
    Taxt.to_string taxt, get_current_user, expansion: false
  end

  def link_to_reference reference, user
    reference.key.to_link user, expansion: false
  end

end
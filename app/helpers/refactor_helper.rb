module RefactorHelper

  # $use_ant_web_formatter is not optimal, but...

  def link_to_taxon taxon
    if $use_ant_web_formatter
      link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
    else
      label = taxon.name.to_html_with_fossil(taxon.fossil?)
      content_tag :a, label, href: %{/catalog/#{taxon.id}}
    end
  end

  def link_to_other_site
    if $use_ant_web_formatter
      link_to_antcat @taxon
    else
      link_to_antweb @taxon
    end
  end

  def link_to_reference reference, user
    if $use_ant_web_formatter
      reference.key.to_link user, expansion: false
    else
      reference.key.to_link user
    end
  end

  def detaxt taxt
    return '' unless taxt.present?
    if $use_ant_web_formatter
      Taxt.to_string taxt, @user, expansion: false
    else
      Taxt.to_string taxt, @user, expansion: true
    end
  end

end

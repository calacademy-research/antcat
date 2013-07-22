# coding: UTF-8
module ChangesHelper

  def format_change_header change, taxon
    "#{User.find(change.whodunnit).name} added <b>#{taxon.name.name_html.html_safe}</b> #{format_time_ago(change.created_at)}".html_safe
  end

  def format_change_attributes taxon
    string = []
    string << 'Fossil' if taxon.fossil?
    string << 'Hong' if taxon.hong?
    string << '<i>nomen nudum</i>' if taxon.nomen_nudum?
    string << 'unresolved homonym' if taxon.unresolved_homonym?
    string << 'ichnotaxon' if taxon.ichnotaxon?
    string.join(', ').html_safe
  end

  def format_change_protonym_attributes taxon
    protonym = taxon.protonym
    string = []
    string << 'Fossil' if protonym.fossil?
    string << '<i>sic</i>' if protonym.sic?
    string.join(', ').html_safe
  end

  def format_change_type_attributes taxon
    string = []
    string << 'Fossil' if taxon.type_fossil?
    string.join(', ').html_safe
  end

  def format_time_ago time
    content_tag :span, "#{time_ago_in_words time} ago", title: time
  end

  def format_taxt taxt
    Taxt.to_string taxt, current_user
  end
end

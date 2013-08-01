# coding: UTF-8
module ChangesHelper

  def format_name name
    name.name_html.html_safe
  end

  def format_adder_name user_id
    "#{user_id ? User.find(user_id).name : 'Someone'} added"
  end

  def format_rank rank
    rank.display_string
  end

  def format_status status
    Status[status].to_s
  end

  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_attributes taxon
    string = []
    string << 'Fossil' if taxon.fossil?
    string << 'Hong' if taxon.hong?
    string << '<i>nomen nudum</i>' if taxon.nomen_nudum?
    string << 'unresolved homonym' if taxon.unresolved_homonym?
    string << 'ichnotaxon' if taxon.ichnotaxon?
    string.join(', ').html_safe
  end

  def format_protonym_attributes taxon
    protonym = taxon.protonym
    string = []
    string << 'Fossil' if protonym.fossil?
    string << '<i>sic</i>' if protonym.sic?
    string.join(', ').html_safe
  end

  def format_type_attributes taxon
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

  def approve_button taxon
    button_to 'Approve', approve_change_path(taxon.last_change), confirm: 'Are you sure you want to approve this change?'
  end

end

module ChangesHelper

  def format_taxon_name name
    name.name_html.html_safe
  end

  def format_rank rank
    rank.display_string
  end

  def format_status status
    Status[status].to_s
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
    if taxon.type_fossil? then 'Fossil' else '' end.html_safe
  end

  def format_taxt taxt
    Taxt.to_string taxt, current_user
  end

  def edit_button taxon
    unless taxon.taxon_state.nil?
      if taxon.can_be_edited_by? current_user
        button 'Edit', 'edit_button', 'data-edit-location' => edit_taxa_path(taxon)
      end
      # else
      #   #TODO make this pretty
      #   return "<Deleted by later edit>"
    end
  end

  def approve_all_button
    if $Milieu.user_is_superadmin? current_user
      button 'Approve all', 'approve_all_button'
    end
  end

end

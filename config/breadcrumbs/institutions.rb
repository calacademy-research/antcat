# rubocop:disable Layout/IndentationConsistency
crumb :institutions do
  link "Institutions", institutions_path
  parent :editors_panel
end

  crumb :institution do |institution|
    if institution.persisted?
      link "#{institution.abbreviation}: #{institution.name}", institution
    else
      link "##{institution.id} [deleted]"
    end
    parent :institutions
  end

    crumb :edit_institution do |institution|
      link "Edit"
      parent :institution, institution
    end

    crumb :institution_history do |institution|
      link "History"
      parent :institution, institution
    end

  crumb :new_institution do
    link "New"
    parent :institutions
  end
# rubocop:enable Layout/IndentationConsistency

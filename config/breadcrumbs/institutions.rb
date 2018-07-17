# rubocop:disable Layout/IndentationConsistency
crumb :institutions do
  link "Institutions", institutions_path
  parent :editors_panel
end

  crumb :institution do |institution|
    link "#{institution.abbreviation}: #{institution.name}", institution
    parent :institutions
  end

    crumb :edit_institution do |institution|
      link "Edit"
      parent :institution, institution
    end

  crumb :new_institution do |_institution|
    link "New"
    parent :institutions
  end
# rubocop:enable Layout/IndentationConsistency

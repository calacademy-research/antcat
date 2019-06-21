# rubocop:disable Layout/IndentationConsistency
crumb :protonyms do
  link "Protonyms", protonyms_path
  parent :catalog
end

  crumb :protonym do |protonym|
    link protonym.decorate.format_name, protonym_path(protonym)
    parent :protonyms
  end

    crumb :edit_protonym do |protonym|
      link 'Edit', edit_protonym_path(protonym)
      parent :protonym, protonym
    end

    crumb :protonym_history do |protonym|
      link "History"
      parent :protonym, protonym
    end

  crumb :new_protonym do
    link "New"
    parent :protonyms
  end
# rubocop:enable Layout/IndentationConsistency

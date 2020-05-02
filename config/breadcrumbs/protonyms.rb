# frozen_string_literal: true

crumb :protonyms do
  link "Protonyms", protonyms_path
  parent :catalog
end

crumb :protonym do |protonym|
  if protonym.persisted?
    link protonym.decorate.name_with_fossil, protonym
  else
    link "##{protonym.id} [deleted]"
  end
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

crumb :protonym_what_links_here do |protonym|
  link "What Links Here"
  parent :protonym, protonym
end

crumb :new_protonym do
  link "New"
  parent :protonyms
end

crumb :protonym_soft_validations do |protonym|
  link "Soft validations"
  parent :protonym, protonym
end

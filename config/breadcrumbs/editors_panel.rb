crumb :editors_panel do
 link "Editor's Panel", editors_panel_path
end

crumb :edit_user do
  link "Edit User"
  parent :editors_panel
end

crumb :invite_people do
  link "Invite People"
  parent :editors_panel
end

crumb :editors_panel do
 link "Editor's Panel", editors_panel_path
end

crumb :tooltips do
  link "Edit Tooltips", tooltips_path
  parent :editors_panel
end

  crumb :tooltip do |tooltip|
    link "Tooltip ##{tooltip.id}", tooltip_path(tooltip)
    parent :tooltips
  end

    crumb :edit_tooltip do |tooltip|
      link "Edit"
      parent :tooltip, tooltip
    end

  crumb :new_tooltip do
    link "New"
    parent :tooltips
  end

crumb :edit_user do
  link "Edit User"
  parent :editors_panel
end

crumb :invite_people do
  link "Invite People"
  parent :editors_panel
end

crumb :user_feedback do
  link "User Feedback"
  parent :editors_panel
end

crumb :lazy_links do
  link "Lazy Links"
  parent :editors_panel
end

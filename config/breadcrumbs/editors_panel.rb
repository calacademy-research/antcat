crumb :editors_panel do
  link "Editor's Panel", editors_panel_path
end

crumb :editors_panel_dashboard do
  link "Dashboard"
  parent :editors_panel
end

crumb :activity_feed do
  link "Activity Feed", activities_path
  parent :editors_panel
end

crumb :activity_item do |activity_id|
  link "Activity Item ##{activity_id}"
  parent :activity_feed
end

crumb :unconfirmed_activities do
  link "Unconfirmed Activities", unconfirmed_activities_path
  parent :activity_feed
end

crumb :search_taxon_history_items do
  link "Search History Items"
  parent :editors_panel
end

crumb :search_reference_sections do
  link "Search Reference Sections"
  parent :editors_panel
end

crumb :comments do
  link "Comments"
  parent :editors_panel
end

crumb :edit_comment do |comment|
  link "Edit Comment ##{comment.id}"
  parent :comments
end

crumb :invite_users do
  link "Invite Users"
  parent :editors_panel
end

crumb :user_feedback do
  link "User Feedback", feedback_index_path
  parent :editors_panel
end

crumb :user_feedback_details do |feedback|
  link "Feedback ##{feedback.id}"
  parent :user_feedback
end

crumb :database_scripts do
  link "Database Scripts", database_scripts_path
  parent :editors_panel
end

crumb :database_script do |script|
  link script.title, database_script_path(script)
  parent :database_scripts
end

crumb :versions do
  link "PaperTrail Versions", versions_path
  parent :editors_panel
end

crumb :version do |version|
  link "##{version.id}", version_path(version)
  parent :versions
end

crumb :about_unconfirmed_users do
  link "About Unconfirmed Users", page_path('unconfirmed_user')
  parent :editors_panel
end

crumb :bolton_keys_to_ref_tags do
  link "Bolton keys to ref tags", bolton_keys_to_ref_tags_path
  parent :editors_panel
end

crumb :notifications do
  link "My Notifications"
  parent :editors_panel
end

crumb :markdown_formatting_help do
  link "Markdown Formatting Help"
  parent :editors_panel
end

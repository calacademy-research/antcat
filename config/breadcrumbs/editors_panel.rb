# rubocop:disable Layout/IndentationConsistency
crumb :editors_panel do
  link "Editor's Panel", editors_panel_path
end

crumb :editors_panel_dashboard do
  link "Dashboard"
  parent :editors_panel
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

    crumb :tooltip_history do |tooltip|
      link "History"
      parent :tooltip, tooltip
    end

  crumb :new_tooltip do
    link "New"
    parent :tooltips
  end

crumb :issues do
  link "Issues", issues_path
  parent :editors_panel
end

  crumb :issue do |issue|
    link "##{issue.id}: #{issue.title}", issue_path(issue)
    parent :issues
  end

    crumb :edit_issue do |issue|
      link "Edit"
      parent :issue, issue
    end

    crumb :issue_history do |issue|
      link "History"
      parent :issue, issue
    end

  crumb :new_issue do |_issue|
    link "New"
    parent :issues
  end

crumb :activity_feed do
  link "Activity Feed", activities_path
  parent :editors_panel
end

  crumb :activity_item do |activity_id|
    link "Activity Item ##{activity_id}"
    parent :activity_feed
  end

crumb :comments do
  link "Comments"
  parent :editors_panel
end

  crumb :edit_comment do |comment|
    link "Edit Comment ##{comment.id}"
    parent :comments
  end

crumb :edit_user do
  link "Edit User"
  parent :editors_panel
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

crumb :site_notices do
  link "Site Notices", site_notices_path
  parent :editors_panel
end

  crumb :site_notice do |site_notice|
    link site_notice.title, site_notice_path(site_notice)
    parent :site_notices
  end

    crumb :edit_site_notice do |site_notice|
      link "Edit"
      parent :site_notice, site_notice
    end

  crumb :new_site_notice do |_site_notice|
    link "New"
    parent :site_notices
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

crumb :lazy_links do
  link "Lazy Links"
  parent :editors_panel
end

crumb :beta_and_such do
  link "Beta and such (testing, debugging)"
  parent :editors_panel
end
# rubocop:enable Layout/IndentationConsistency

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

crumb :tasks do
  link "Open Tasks", tasks_path
  parent :editors_panel
end

  crumb :task do |task|
    link "##{task.id}: #{task.title}", task_path(task)
    parent :tasks
  end

    crumb :edit_task do |task|
      link "Edit"
      parent :task, task
    end

  crumb :new_task do |task|
    link "New"
    parent :tasks
  end

crumb :feed do
  link "Feed"
  parent :editors_panel
end

crumb :comments do
  link "Comments"
  parent :editors_panel
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

  crumb :new_site_notice do |site_notice|
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

    crumb :show_database_script_source do |script|
      link "Show Source"
      parent :database_script, script
    end

crumb :markdown_formatting_help do
  link "Markdown Formatting Help"
  parent :editors_panel
end

crumb :lazy_links do
  link "Lazy Links"
  parent :editors_panel
end

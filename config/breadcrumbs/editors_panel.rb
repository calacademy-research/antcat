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
    link "Task ##{task.id}", task_path(task)
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

crumb :lazy_links do
  link "Lazy Links"
  parent :editors_panel
end

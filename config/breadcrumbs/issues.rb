# frozen_string_literal: true

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

crumb :new_issue do
  link "New"
  parent :issues
end

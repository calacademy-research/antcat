crumb :changes do
  link "Changes", changes_path
end

crumb :change do |change|
  link "Change ##{change.id}", change_path(change)
  parent :changes
end

crumb :confirm_before_undo_change do |change|
  link "Confirm before undo"
  parent :change, change
end

crumb :all_changes do
  link "All Changes", changes_path
  parent :changes
end

crumb :unreviewed_changes do
  link "Unreviewed Changes", unreviewed_changes_path
  parent :changes
end

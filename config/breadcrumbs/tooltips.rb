# frozen_string_literal: true

crumb :tooltips do
  link "Edit Tooltips", tooltips_path
  parent :editors_panel
end

crumb :tooltip do |tooltip|
  if tooltip.persisted?
    link "Tooltip ##{tooltip.id}", tooltip_path(tooltip)
  else
    link "##{tooltip.id} [deleted]"
  end
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

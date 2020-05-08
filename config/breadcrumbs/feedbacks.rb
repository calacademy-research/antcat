# frozen_string_literal: true

crumb :feedbacks do
  link "User Feedback", feedbacks_path
  parent :editors_panel
end

crumb :feedback do |feedback|
  link "Feedback ##{feedback.id}", feedback
  parent :feedbacks
end

crumb :edit_feedback do |feedback|
  link "Edit"
  parent :feedback, feedback
end

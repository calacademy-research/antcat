# frozen_string_literal: true

crumb :journals do
  link "Journals", journals_path
  parent :references
end

crumb :journal do |journal|
  link tag.i(journal.name), journal_path(journal)
  parent :journals
end

crumb :edit_journal do |journal|
  link "Edit"
  parent :journal, journal
end

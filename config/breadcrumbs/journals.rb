# rubocop:disable Layout/IndentationConsistency
crumb :journals do
  link "Journals", journals_path
  parent :references
end

  crumb :journal do |journal|
    link italicize(journal.name), journal_path(journal)
    parent :journals
  end

    crumb :edit_journal do |journal|
      link "Edit"
      parent :journal, journal
    end
# rubocop:enable Layout/IndentationConsistency

# rubocop:disable Layout/IndentationConsistency
crumb :references do
  link "References", references_path
end

  crumb :reference do |reference|
    link reference.keey, reference_path(reference)
    parent :references
  end

  crumb :new_reference do
    link "New"
    parent :references
  end

  crumb :edit_reference do |reference|
    link "Edit"
    parent :reference, reference
  end

  crumb :reference_history do |reference|
    link "History"
    parent :reference, reference
  end

  crumb :reference_what_links_here do |reference|
    link "What Links Here"
    parent :reference, reference
  end

crumb :references_search_results do
  link "Search Results"
  parent :references
end

crumb :references_search_help do
  link "Search Help"
  parent :references
end

crumb :all_references do
  link "All References", references_path
  parent :references
end

crumb :references_latest_additions do
  link "Latest Additions", references_latest_additions_path
  parent :references
end

crumb :references_latest_changes do
  link "Latest Changes", references_latest_changes_path
  parent :references
end

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

  crumb :new_journal do
    link "New Journal"
    parent :journals
  end

crumb :authors do
  link "Authors", authors_path
  parent :references
end

  crumb :author do |author|
    link author.first_author_name_name, author
    parent :authors
  end

    crumb :new_author_name do |author|
      link "Add author name"
      parent :author, author
    end

    crumb :edit_author_name do |author_name|
      link "Edit author name"
      parent :author, author_name.author
    end

  crumb :merge_authors do
    link "Merge Authors"
    parent :authors
  end
# rubocop:enable Layout/IndentationConsistency

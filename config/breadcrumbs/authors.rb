# rubocop:disable Layout/IndentationConsistency
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

  crumb :merge_authors do |author|
    link "Merge Authors"
    parent :author, author
  end
# rubocop:enable Layout/IndentationConsistency

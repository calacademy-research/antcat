# frozen_string_literal: true

crumb :wiki_pages do
  link "Help pages", wiki_pages_path
  parent :policies_and_help
end

crumb :wiki_page do |wiki_page|
  if wiki_page.persisted?
    link wiki_page.title, wiki_page
  else
    link "##{wiki_page.id} [deleted]"
  end
  # A policy page sits under "Policies", any other page under "Help pages".
  parent(wiki_page.policy? ? :policies : :wiki_pages)
end

crumb :edit_wiki_page do |wiki_page|
  link "Edit"
  parent :wiki_page, wiki_page
end

crumb :wiki_page_history do |wiki_page|
  link "History"
  parent :wiki_page, wiki_page
end

crumb :new_wiki_page do
  link "New"
  parent :wiki_pages
end

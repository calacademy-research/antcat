crumb :wiki_pages do
  link "Wiki Pages", wiki_pages_path
  parent :editors_panel
end

crumb :wiki_page do |wiki_page|
  if wiki_page.persisted?
    link "##{wiki_page.id}: #{wiki_page.title}", wiki_page
  else
    link "##{wiki_page.id} [deleted]"
  end
  parent :wiki_pages
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

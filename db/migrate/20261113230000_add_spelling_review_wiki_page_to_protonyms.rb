# frozen_string_literal: true

# The AntCat wiki page that documents the review behind a protonym's part of speech and accepted
# spelling: its evidence, reasoning and decision (Brian Fisher, 13 Nov 2026). Optional, because most
# names need no review page. Linked by id, so renaming the page keeps the link.
class AddSpellingReviewWikiPageToProtonyms < ActiveRecord::Migration[8.1]
  def change
    add_column :protonyms, :spelling_review_wiki_page_id, :bigint
    add_index :protonyms, :spelling_review_wiki_page_id, name: "ix_protonyms__spelling_review_wiki_page_id"
    add_foreign_key :protonyms, :wiki_pages, column: :spelling_review_wiki_page_id,
      name: "fk_protonyms__spelling_review_wiki_page_id__wiki_pages__id"
  end
end

# frozen_string_literal: true

# The AntCat wiki page "Grammar and spelling: <name>" that documents the evidence, reasoning and decision
# behind a protonym's part of speech and accepted spelling (Brian Fisher, 13 Nov 2026). Optional, because
# most names need no such page. Linked by id, so renaming the page keeps the link.
class AddGrammarAndSpellingWikiPageToProtonyms < ActiveRecord::Migration[8.1]
  def change
    add_column :protonyms, :grammar_and_spelling_wiki_page_id, :bigint
    add_index :protonyms, :grammar_and_spelling_wiki_page_id, name: "ix_protonyms__grammar_and_spelling_wiki_page_id"
    add_foreign_key :protonyms, :wiki_pages, column: :grammar_and_spelling_wiki_page_id,
      name: "fk_protonyms__grammar_and_spelling_wiki_page_id__wiki_pages__id"
  end
end

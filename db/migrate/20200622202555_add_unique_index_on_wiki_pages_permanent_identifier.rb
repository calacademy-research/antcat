# frozen_string_literal: true

class AddUniqueIndexOnWikiPagesPermanentIdentifier < ActiveRecord::Migration[6.0]
  def change
    add_index :wiki_pages, :permanent_identifier, unique: true, name: :ux_wiki_pages__permanent_identifier
  end
end

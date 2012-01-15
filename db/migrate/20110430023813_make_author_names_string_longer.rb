# coding: UTF-8
class MakeAuthorNamesStringLonger < ActiveRecord::Migration
  def self.up
    remove_index :references, name: "references_author_names_string_citation_year_idx"
    change_column :references, :author_names_string_cache, :text
    add_index :references, [:author_names_string_cache, :citation_year], name: "references_author_names_string_citation_year_idx", length: {author_names_string_cache: 5000}
  end

  def self.down
    remove_index :references, name: "references_author_names_string_citation_year_idx"
    change_column :references, :author_names_string_cache, :string
    add_index :references, [:author_names_string_cache, :citation_year], name: "references_author_names_string_citation_year_idx"
  end
end

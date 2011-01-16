class MakeAuthorNamesStringVarChar < ActiveRecord::Migration
  def self.up
    execute 'DROP INDEX references_authors_string_citation_year_idx ON `references`'
    change_column :references, :author_names_string, :string, :length => 1000
    add_index :references, [:author_names_string, :citation_year], :name => 'references_author_names_string_citation_year_idx'
  end

  def self.down
    execute 'DROP INDEX references_author_names_string_citation_year_idx ON `references`'
    change_column :references, :author_names_string, :text
    add_index :references, [:author_names_string, :citation_year], :name => 'references_authors_string_citation_year_idx', :length => {:author_names_string => 100}
  end
end

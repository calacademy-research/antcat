class RenameBoltonCitationKey < ActiveRecord::Migration
  def self.up
    rename_column :references, :bolton_citation_key, :bolton_author_year_key
  end

  def self.down
    rename_column :references, :bolton_author_year_key, :bolton_citation_key
  end
end

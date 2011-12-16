class AddBoltonCitationKey < ActiveRecord::Migration
  def self.up
    add_column :references, :bolton_citation_key, :string
    add_index :references, :bolton_citation_key
  end

  def self.down
    remove_index :references, :column => :bolton_citation_key
    remove_column :references, :bolton_citation_key
  end
end

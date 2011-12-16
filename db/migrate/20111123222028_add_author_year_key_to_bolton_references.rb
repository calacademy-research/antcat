class AddAuthorYearKeyToBoltonReferences < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :author_year_key, :string
  end

  def self.down
    remove_column :bolton_references, :author_year_key
  end
end

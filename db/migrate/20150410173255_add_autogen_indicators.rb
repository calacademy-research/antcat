class AddAutogenIndicators < ActiveRecord::Migration[4.2]
  def change
    add_column :taxa, :auto_generated, :boolean, default: false
    add_column :names, :auto_generated, :boolean, default: false
    add_column :citations, :auto_generated, :boolean, default: false
    add_column :references, :auto_generated, :boolean, default: false
    add_column :journals, :auto_generated, :boolean, default: false
    add_column :author_names, :auto_generated, :boolean, default: false
    add_column :protonyms, :auto_generated, :boolean, default: false
    add_column :reference_author_names, :auto_generated, :boolean, default: false
    add_column :synonyms, :auto_generated, :boolean, default: false

    add_column :taxa, :origin, :string
    add_column :names, :origin, :string
    add_column :citations, :origin, :string
    add_column :references, :origin, :string
    add_column :journals, :origin, :string
    add_column :author_names, :origin, :string
    add_column :protonyms, :origin, :string
    add_column :reference_author_names, :origin, :string
    add_column :synonyms, :origin, :string
  end
end

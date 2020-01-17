class AddPermanentIdentifierToWikiPages < ActiveRecord::Migration[5.2]
  def change
    add_column :wiki_pages, :permanent_identifier, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE wiki_pages
            SET permanent_identifier = 'new_contributors_help_page'
            WHERE id = 1;
        SQL
      end
    end
  end
end

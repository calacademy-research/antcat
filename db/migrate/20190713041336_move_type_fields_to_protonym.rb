class MoveTypeFieldsToProtonym < ActiveRecord::Migration[5.2]
  def change
    add_column :protonyms, :primary_type_information_taxt, :text
    add_column :protonyms, :secondary_type_information_taxt, :text
    add_column :protonyms, :type_notes_taxt, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
              AND (taxa.primary_type_information IS NOT NULL)
            SET protonyms.primary_type_information_taxt = taxa.primary_type_information;
        SQL

        execute <<~SQL
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
              AND (taxa.secondary_type_information IS NOT NULL)
            SET protonyms.secondary_type_information_taxt = taxa.secondary_type_information;
        SQL

        execute <<~SQL
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
              AND (taxa.type_notes IS NOT NULL)
            SET protonyms.type_notes_taxt = taxa.type_notes;
        SQL
      end
    end
  end
end

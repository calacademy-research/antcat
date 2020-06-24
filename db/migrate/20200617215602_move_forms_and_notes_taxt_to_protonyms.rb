# frozen_string_literal: true

class MoveFormsAndNotesTaxtToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :forms, :string
    add_column :protonyms, :notes_taxt, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE protonyms
            INNER JOIN citations ON protonyms.authorship_id = citations.id
            SET
              protonyms.forms = citations.forms,
              protonyms.notes_taxt = citations.notes_taxt;
        SQL
      end
    end
  end
end

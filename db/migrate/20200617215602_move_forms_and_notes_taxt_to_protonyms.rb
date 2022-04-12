# frozen_string_literal: true

class MoveFormsAndNotesTaxtToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :forms, :string
    add_column :protonyms, :notes_taxt, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE protonyms
            INNER JOIN citations ON citations.id = protonyms.authorship_id
            SET
              protonyms.forms = citations.forms,
              protonyms.notes_taxt = citations.notes_taxt;
        SQL
      end
    end
  end
end

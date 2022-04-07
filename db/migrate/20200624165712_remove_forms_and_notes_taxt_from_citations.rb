# frozen_string_literal: true

class RemoveFormsAndNotesTaxtFromCitations < ActiveRecord::Migration[6.0]
  def up
    remove_column :citations, :notes_taxt, :text
    remove_column :citations, :forms, :string
  end

  def down
    add_column :citations, :notes_taxt, :text
    add_column :citations, :forms, :string

    execute <<~SQL.squish
      UPDATE citations
        INNER JOIN protonyms ON citations.id = protonyms.authorship_id
        SET
          citations.forms = protonyms.forms,
          citations.notes_taxt = protonyms.notes_taxt;
    SQL
  end
end

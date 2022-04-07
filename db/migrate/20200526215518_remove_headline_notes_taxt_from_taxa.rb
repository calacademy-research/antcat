# frozen_string_literal: true

class RemoveHeadlineNotesTaxtFromTaxa < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxa, :headline_notes_taxt, :text
  end
end

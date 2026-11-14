# frozen_string_literal: true

# A note printed right after a history item's citation, kept exactly as printed: "[Myrmicidae]" (the name the cited
# author used), "[provisional]", "(see note in bibliography)" (2026-11-14).
class AddCitationNoteToHistoryItems < ActiveRecord::Migration[8.1]
  def change
    add_column :history_items, :citation_note, :string
  end
end

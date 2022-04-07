# frozen_string_literal: true

class AddForceAuthorCitationToHistoryItems < ActiveRecord::Migration[6.1]
  def change
    add_column :history_items, :force_author_citation, :boolean, default: false, null: false
  end
end

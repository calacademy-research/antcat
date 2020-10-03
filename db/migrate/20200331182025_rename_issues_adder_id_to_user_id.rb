# frozen_string_literal: true

class RenameIssuesAdderIdToUserId < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_foreign_key :issues, :users, column: :adder_id, name: "fk_issues__adder_id__users__id"
      rename_column :issues, :adder_id, :user_id
      add_foreign_key :issues, :users, name: "fk_issues__user_id__users__id"
    end
  end
end

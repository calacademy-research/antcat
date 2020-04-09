# frozen_string_literal: true

class AddAuthorIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :author_id, :integer
    add_index :users, :author_id, unique: true
    add_foreign_key :users, :authors, name: "fk_users__author_id__authors__id"
  end
end

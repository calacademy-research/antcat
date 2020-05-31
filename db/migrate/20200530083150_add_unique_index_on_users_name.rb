# frozen_string_literal: true

class AddUniqueIndexOnUsersName < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :name, unique: true, name: :ux_users__name
  end
end

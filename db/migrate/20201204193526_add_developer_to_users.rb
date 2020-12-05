# frozen_string_literal: true

class AddDeveloperToUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :users, :developer, :boolean, default: false, null: false
    end
  end
end

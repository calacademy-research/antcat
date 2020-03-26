# frozen_string_literal: true

class AddNotNullsToNameIds < ActiveRecord::Migration[6.0]
  def change
    change_column_null :protonyms, :name_id, false
    change_column_null :taxa, :name_id, false
  end
end

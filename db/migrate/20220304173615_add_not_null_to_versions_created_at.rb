# frozen_string_literal: true

class AddNotNullToVersionsCreatedAt < ActiveRecord::Migration[7.0]
  def change
    change_column_null :versions, :created_at, false
  end
end

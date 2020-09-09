# frozen_string_literal: true

class AddNotNullToReferencesPages < ActiveRecord::Migration[6.0]
  def up
    change_column_null :references, :pagination, false
  end

  def down
    change_column_null :references, :pagination, true
  end
end

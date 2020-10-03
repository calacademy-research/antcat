# frozen_string_literal: true

class AddNotNullToReferencesPages < ActiveRecord::Migration[6.0]
  def up
    safety_assured do
      change_column_null :references, :pagination, false
    end
  end

  def down
    change_column_null :references, :pagination, true
  end
end

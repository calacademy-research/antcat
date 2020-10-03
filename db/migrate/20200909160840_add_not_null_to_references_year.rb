# frozen_string_literal: true

class AddNotNullToReferencesYear < ActiveRecord::Migration[6.0]
  def up
    safety_assured do
      change_column_null :references, :year, false
    end
  end

  def down
    change_column_null :references, :year, true
  end
end

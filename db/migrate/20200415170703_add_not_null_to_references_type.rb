# frozen_string_literal: true

class AddNotNullToReferencesType < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      change_column_null :references, :type, false
    end
  end
end

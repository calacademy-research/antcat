# frozen_string_literal: true

class AddNotNullToReferencesType < ActiveRecord::Migration[6.0]
  def change
    change_column_null :references, :type, false
  end
end

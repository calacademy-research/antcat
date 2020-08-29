# frozen_string_literal: true

class AddNotNullToCleanedNameNames < ActiveRecord::Migration[6.0]
  def change
    change_column_null :names, :cleaned_name, false
  end
end

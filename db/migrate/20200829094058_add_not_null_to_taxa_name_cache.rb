# frozen_string_literal: true

class AddNotNullToTaxaNameCache < ActiveRecord::Migration[6.0]
  def change
    change_column_null :taxa, :name_cache, false
  end
end

# frozen_string_literal: true

class AddNotNullsToNames < ActiveRecord::Migration[6.0]
  def change
    change_column_null :names, :type, false
    change_column_null :names, :name, false
    change_column_null :names, :epithet, false
  end
end

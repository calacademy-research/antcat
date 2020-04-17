# frozen_string_literal: true

class AddStatedYearToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :stated_year, :string
  end
end

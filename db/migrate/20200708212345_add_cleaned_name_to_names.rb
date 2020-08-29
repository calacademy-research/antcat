# frozen_string_literal: true

class AddCleanedNameToNames < ActiveRecord::Migration[6.0]
  def change
    add_column :names, :cleaned_name, :string
  end
end

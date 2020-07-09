# frozen_string_literal: true

class AddCleanedNameToNames < ActiveRecord::Migration[6.0]
  def change
    # TODO: Make NOT NULL.
    add_column :names, :cleaned_name, :string
  end
end

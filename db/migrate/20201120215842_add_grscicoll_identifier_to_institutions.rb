# frozen_string_literal: true

class AddGrscicollIdentifierToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :grscicoll_identifier, :string
  end
end

# frozen_string_literal: true

class RemovePagesInFromReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :references, :pages_in, :string
  end
end

# frozen_string_literal: true

class RemovePagesInFromReferences < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :references, :pages_in, :string
    end
  end
end

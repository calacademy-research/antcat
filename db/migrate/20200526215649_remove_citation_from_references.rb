# frozen_string_literal: true

class RemoveCitationFromReferences < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :references, :citation, :text
    end
  end
end

# frozen_string_literal: true

class RemoveCitationFromReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :references, :citation, :text
  end
end

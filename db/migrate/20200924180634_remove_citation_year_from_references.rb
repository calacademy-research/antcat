# frozen_string_literal: true

class RemoveCitationYearFromReferences < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :references, :citation_year, :string
    end
  end
end

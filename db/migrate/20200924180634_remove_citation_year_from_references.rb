# frozen_string_literal: true

class RemoveCitationYearFromReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :references, :citation_year, :string
  end
end

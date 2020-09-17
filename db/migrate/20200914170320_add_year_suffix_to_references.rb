# frozen_string_literal: true

# TODO: Remove `references.citation_year`.
#   rails g migration RemoveCitationYearFromReferences
#   remove_column :references, :citation_year, :string

class AddYearSuffixToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :year_suffix, :string, limit: 2

    # Expected: `Reference.where("CONCAT_WS('', year, year_suffix) != citation_year").count # 0`.
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE `references`
            SET year_suffix = NULLIF(SUBSTR(citation_year, 5, 1), '');
        SQL
      end
    end
  end
end

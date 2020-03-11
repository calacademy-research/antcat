# TODO: Remove `references.pages_in`.

class CopyReferencesPagesInToPagination < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      UPDATE `references` SET pagination = pages_in WHERE type = 'NestedReference'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE `references` SET pages_in = pagination WHERE type = 'NestedReference'
    SQL
  end
end

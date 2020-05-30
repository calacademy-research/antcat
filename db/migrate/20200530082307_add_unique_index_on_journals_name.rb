# frozen_string_literal: true

class AddUniqueIndexOnJournalsName < ActiveRecord::Migration[6.0]
  def up
    remove_index :journals, name: :journals_name_idx
    add_index :journals, :name, unique: true, name: :ux_journals__name
  end

  def down
    add_index :journals, :name, name: :journals_name_idx
    remove_index :journals, name: :ux_journals__name
  end
end

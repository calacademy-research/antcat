# frozen_string_literal: true

# Migration for renaming `activities.action` to `activities.event`.
# TODO: `change_column_null :activities, :event, false`.
# TODO: `remove_column :activities, :action, :string`.
class AddEventToActivities < ActiveRecord::Migration[7.0]
  def up
    add_column :activities, :event, :string

    execute <<~SQL.squish
      UPDATE activities SET event = action WHERE event IS NULL;
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE activities SET action = event WHERE action IS NULL;
    SQL

    remove_column :activities, :event, :string
  end
end

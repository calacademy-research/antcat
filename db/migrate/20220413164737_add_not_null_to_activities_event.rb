# frozen_string_literal: true

class AddNotNullToActivitiesEvent < ActiveRecord::Migration[7.0]
  def up
    change_column_null :activities, :event, false
  end

  def down
    change_column_null :activities, :event, true
  end
end

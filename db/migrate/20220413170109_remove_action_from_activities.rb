# frozen_string_literal: true

class RemoveActionFromActivities < ActiveRecord::Migration[7.0]
  def up
    remove_column :activities, :action, :string
  end

  def down
    add_column :activities, :action, :string
  end
end

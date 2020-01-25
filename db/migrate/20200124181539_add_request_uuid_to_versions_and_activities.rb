class AddRequestUuidToVersionsAndActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :request_uuid, :string
    add_index :versions, :request_uuid

    add_column :activities, :request_uuid, :string
    add_index :activities, :request_uuid
  end
end

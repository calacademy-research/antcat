# TODO: Remove blanked data migrations like this one.

class DropOrderName < ActiveRecord::Migration[4.2]
  def up
    # Name.where(type: "OrderName").delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end

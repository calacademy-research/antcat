class DropOrderName < ActiveRecord::Migration
  def up
    Name.where(type: "OrderName").delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end

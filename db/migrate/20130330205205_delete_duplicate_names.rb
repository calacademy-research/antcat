class DeleteDuplicateNames < ActiveRecord::Migration
  def up
    Name.destroy_duplicates show_progress: true
  end

  def down
  end
end

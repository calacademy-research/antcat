class FixEli < ActiveRecord::Migration
  def up
    Reference.find(127098).replace_with(Reference.find(142254), show_progress: true)
  end

  def down
  end
end

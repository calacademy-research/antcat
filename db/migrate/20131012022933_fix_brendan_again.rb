class FixBrendanAgain < ActiveRecord::Migration
  def up
    User.destroy_all "email = 'boudinot@gmail.com'"
  end

  def down
  end
end

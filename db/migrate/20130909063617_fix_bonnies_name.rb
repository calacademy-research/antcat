class FixBonniesName < ActiveRecord::Migration
  def up
    bonnie = User.find_by_email 'bonnieblaimer@gmail.com'
    bonnie.update_attributes! name: 'Bonnie Blaimer'
  end

  def down
  end
end

class ChangeANetNewsletter < ActiveRecord::Migration
  def self.up
    Journal.find_by_name('ANet Newsletter').update_attribute :name, 'ANeT Newsletter'
  end

  def self.down
  end
end

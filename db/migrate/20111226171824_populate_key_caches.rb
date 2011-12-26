class PopulateKeyCaches < ActiveRecord::Migration
  def self.up
    Bolton::Reference.set_key_caches
  end

  def self.down
  end
end

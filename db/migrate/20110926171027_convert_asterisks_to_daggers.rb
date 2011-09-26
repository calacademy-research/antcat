class ConvertAsterisksToDaggers < ActiveRecord::Migration
  def self.up
    Taxon.all.each do |taxon|
      taxon.convert_asterisks_to_daggers!
    end
  end

  def self.down
  end
end

class ClearLostPdfUrls < ActiveRecord::Migration
  def self.up
    [
    126952,
    126968,
    130626,
    130895,
    132508,
    132729,
    ].each do |id|
      reference = Reference.find id
      puts reference.url
      reference.document = nil
      reference.source_url = nil
      reference.save!
    end
  end

  def self.down
  end
end

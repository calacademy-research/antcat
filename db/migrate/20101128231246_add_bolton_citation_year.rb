class AddBoltonCitationYear < ActiveRecord::Migration
  def self.up
    change_table :bolton_references do |t|
      begin
        t.remove :year
        t.remove :citation_year
      rescue
      end
      t.integer :year
      t.string :citation_year
    end
  end

  def self.down
  end
end

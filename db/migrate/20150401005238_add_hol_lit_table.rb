class AddHolLitTable < ActiveRecord::Migration[4.2]
  def change
    create_table :hol_literatures do |t|
      t.integer :tnuid
      t.integer :pub_id
      t.string :taxon
      t.string :name
      t.string :describer
      t.string :rank
      t.string :year
      t.string :month
      t.string :comments
      t.string :full_pdf
      t.string :pages
      t.string :public
      t.string :author
    end

    create_table "hol_literature_pages" do |t|
      t.integer :literatures_id
      t.string :url
      t.string :page
    end
  end
end

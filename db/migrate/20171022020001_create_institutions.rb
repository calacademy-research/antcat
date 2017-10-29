class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :abbreviation, null: false
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :institutions, :abbreviation, unique: true
  end
end

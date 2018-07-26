class AddBoltonKeyToReferences < ActiveRecord::Migration[5.1]
  def change
    add_column :references, :bolton_key, :string
  end
end

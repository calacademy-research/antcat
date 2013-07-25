class CreateTaxonReviewState < ActiveRecord::Migration
  def up
    add_column :taxa, :review_status, :string
  end
end

class RemoveVerifiedFromPlaces < ActiveRecord::Migration[4.2]
  def change
    remove_column :places, :verified, :boolean, default: false
  end
end

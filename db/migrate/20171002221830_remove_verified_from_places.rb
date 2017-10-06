class RemoveVerifiedFromPlaces < ActiveRecord::Migration
  def change
    remove_column :places, :verified, :boolean, default: false
  end
end

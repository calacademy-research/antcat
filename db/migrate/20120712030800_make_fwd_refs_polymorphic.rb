class MakeFwdRefsPolymorphic < ActiveRecord::Migration
  def change
    add_column :species_group_forward_refs, :fixee_type, :string
  end
end

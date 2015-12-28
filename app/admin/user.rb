ActiveAdmin.register User do
  permit_params :email, :can_edit, :is_superadmin, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :can_edit
    column :is_superadmin
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :can_edit
  filter :is_superadmin
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :can_edit
      f.input :is_superadmin
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end

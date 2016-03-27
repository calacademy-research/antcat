ActiveAdmin.register Feedback do
  index do
    selectable_column
    id_column
    column :comment
    column :page
    column :user
    column :name
    column :email
    column :email_recipients
    column :ip
  end
end

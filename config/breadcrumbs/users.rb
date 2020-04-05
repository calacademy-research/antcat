# frozen_string_literal: true

crumb :users do
  link "Users", users_path
  parent :antcat
end

crumb :user do |user|
  link user.name, user_path(user)
  parent :users
end

crumb :superadmin_edit_user do |user|
  link "Edit as Superadmin"
  parent :user, user
end

crumb :my_account do |user|
  link "My account"
  parent :user, user
end

crumb :new_user do
  link "New"
  parent :users
end

# rubocop:disable Layout/IndentationConsistency
crumb :antcat do
  link "AntCat", root_path
end

crumb :about do
  link "About", page_path('about')
  parent :antcat
end

crumb :contribute do
  link "Contribute", page_path('contribute')
  parent :antcat
end

crumb :users do
  link "Users", users_path
  parent :antcat
end

  crumb :user do |user|
    link user.name, user_path(user)
    parent :users
  end

    crumb :edit_user do |user|
      link "Edit"
      parent :user, user
    end

  crumb :new_user do
    link "New"
    parent :users
  end

crumb :sign_up do
  link "Sign Up"
  parent :antcat
end

crumb :login do
  link "Login"
  parent :antcat
end

crumb :forgot_password do
  link "Forgot Password"
  parent :antcat
end

crumb :change_password do
  link "Change Password"
  parent :antcat
end
# rubocop:enable Layout/IndentationConsistency

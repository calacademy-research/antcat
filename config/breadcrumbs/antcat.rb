crumb :antcat do
  link "AntCat"
end

crumb :about do
  link "About", page_path('about')
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

  crumb :user_emails do
    link "User Emails"
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

crumb :antcat do
  link "AntCat", root_path
end

crumb :about do
  link "About", page_path('about')
  parent :antcat
end

crumb :suggest_edit do
  link "Suggest Edit"
  parent :antcat
end

crumb :contribute do
  link "Contribute", page_path('contribute')
  parent :antcat
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

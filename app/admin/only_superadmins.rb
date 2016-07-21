class OnlySuperadmins < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    user.is_superadmin?
  end
end
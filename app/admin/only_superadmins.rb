class OnlySuperadmins < ActiveAdmin::AuthorizationAdapter
  def authorized? _action, _subject = nil
    user.is_superadmin?
  end
end

module SiteNoticesHelper
  def user_has_unread_site_notices? user
    return false unless user
    SiteNotice.unread_by(user).exists?
  end
end

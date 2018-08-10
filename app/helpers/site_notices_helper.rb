module SiteNoticesHelper
  def show_unread_site_notices?
    # Don't show on catalog pages because it doesn't work well with the fixed layout.
    return false if controller_name == "catalog"

    user_has_unread_site_notices?(current_user) &&
      !most_recent_site_notice_already_dismissed?(session[:last_dismissed_site_notice_id])
  end

  def user_has_unread_site_notices? user
    return false unless user.try :can_edit?
    SiteNotice.unread_by(user).exists?
  end

  private

    def most_recent_site_notice_already_dismissed? last_dismissed_id
      return false unless last_dismissed_id

      last_site_notice_id = SiteNotice.last.try :id
      return false unless last_site_notice_id # There are 0 notices in the database.

      last_site_notice_id <= last_dismissed_id
    end
end

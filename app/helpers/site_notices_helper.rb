module SiteNoticesHelper
  def format_blurb markdown
    stripped = strip_markdown markdown
    truncate stripped, length: 200, omission: "... (continued)"
  end

  def show_unread_site_notices?
    user_has_unread_site_notices?(current_user) &&
      !most_recent_site_notice_already_dismissed?(session[:last_dismissed_site_notice_id])
  end

  def user_has_unread_site_notices? user
    return unless user.try :can_edit?
    SiteNotice.unread_by(user).exists?
  end

  private
    def most_recent_site_notice_already_dismissed? last_dismissed_id
      return unless last_dismissed_id

      last_site_notice_id = SiteNotice.last.try :id
      return unless last_site_notice_id # There are 0 notices in the database.

      last_site_notice_id <= last_dismissed_id
    end
end

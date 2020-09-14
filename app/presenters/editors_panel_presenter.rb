# frozen_string_literal: true

class EditorsPanelPresenter
  MAX_FEATURED_WIKI_PAGES_LINKS = Settings.editors_panel.max_featured_wiki_pages_links

  attr_private_initialize :current_user

  def recent_activities
    Activity.non_automated_edits.most_recent_first.limit(10).includes(:user)
  end

  def recent_comments
    Comment.most_recent_first.limit(5)
  end

  def recent_unconfirmed_activities
    Activity.unconfirmed.most_recent_first.limit(5).includes(:user)
  end

  def open_issues_count
    Issue.open.count
  end

  def unreviewed_references_count
    Reference.unreviewed.count
  end

  def pending_user_feedbacks_count
    Feedback.pending.count
  end

  def featured_wiki_pages
    @_featured_wiki_pages ||= WikiPage.featured.order(:title).select(:id, :title).limit(MAX_FEATURED_WIKI_PAGES_LINKS)
  end

  def total_wiki_pages_count
    @_total_wiki_pages_count ||= WikiPage.count
  end

  def see_more_wiki_pages?
    total_wiki_pages_count > featured_wiki_pages.count
  end
end
